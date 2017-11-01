class HomeController < ApplicationController
  before_filter :require_user, only: %i[subscriptions nearby]

  # caches_action :index, :cache_path => proc { |c|
  #  node = Node.find :last #c.params[:id]
  #  { :n => node.updated_at.to_i }
  # end

  # caches_action :index, :cache_path => { :last => Node.find(:last).updated_at.to_i }

  def home
    @activity, @blog, @notes, @wikis, @revisions, @comments, @answer_comments = Rails.cache.fetch("front-activity", expires_in: 10.minutes) do
      self.activity
    end

    @title = I18n.t('home_controller.science_community')
    if current_user
      redirect_to '/dashboard'
    else
      render template: 'home/home'
    end
  end

  # proxy to enable AJAX loading of RSS feeds, which requires same-origin
  def fetch
    if true # Rails.env.production?
      if params[:url][0..24] == 'https://groups.google.com' || params[:url] == 'https://feeds.feedburner.com/rssmixer/ZvcX'
        url = URI.parse(params[:url])
        result = Net::HTTP.get_response(url)
        send_data result.body, type: result.content_type, disposition: 'inline'
      end
    else
      redirect_to params[:url]
    end
  end

  # route for seeing the front page even if you are logged in
  def front
    @title = I18n.t('home_controller.environmental_investigation')
    @activity, @blog, @notes, @wikis, @revisions, @comments, @answer_comments = Rails.cache.fetch("front-activity", expires_in: 10.minutes) do
      self.activity
    end
    render template: 'home/home'
  end

  def dashboard2
    redirect_to '/dashboard'
  end

  def dashboard
    @note_count = Node.select(%i[created type status])
                      .where(type: 'note', status: 1, created: Time.now.to_i - 1.weeks.to_i..Time.now.to_i)
                      .count
    @wiki_count = Revision.select(:timestamp)
                          .where(timestamp: Time.now.to_i - 1.weeks.to_i..Time.now.to_i)
                          .count
    @user_note_count = Node.where(type: 'note', status: 1, uid: current_user.uid).count if current_user
    @activity, @blog, @notes, @wikis, @revisions, @comments, @answer_comments = self.activity
    render template: 'dashboard/dashboard'
    @title = I18n.t('home_controller.community_research') unless current_user
  end

  # trashy... clean this up!
  # this will eventually be based on the profile_tags data where people can mark their location with "location:lat,lon"
  def nearby
    if current_user.lat
      dist = 1.5
      minlat = current_user.lat - dist
      maxlat = current_user.lat + dist
      minlon = current_user.lon - dist
      maxlon = current_user.lon + dist
      @users = DrupalUsers.where('lat != 0.0 AND lon != 0.0 AND lat > ? AND lat < ? AND lon > ? AND lon < ?', minlat, maxlat, minlon, maxlon)
    end
  end

  def activity
    blog = Tag.find_nodes_by_type('blog', 'note', 1).first
    # remove "classroom" postings; also switch to an EXCEPT operator in sql, see https://github.com/publiclab/plots2/issues/375
    hidden_nids = Node.joins(:node_tag)
                      .joins('LEFT OUTER JOIN term_data ON term_data.tid = community_tags.tid')
                      .select('node.*, term_data.*, community_tags.*')
                      .where(type: 'note', status: 1)
                      .where('term_data.name = (?)', 'hidden:response')
                      .collect(&:nid)
    notes = Node.where(type: 'note')
                .where('node.nid NOT IN (?)', hidden_nids + [0]) # in case hidden_nids is empty
                .order('nid DESC')
                .page(params[:page])
    notes = notes.where('nid != (?)', blog.nid) if blog

    if current_user && (current_user.role == 'moderator' || current_user.role == 'admin')
      notes = notes.where('(node.status = 1 OR node.status = 4)')
    elsif current_user
      notes = notes.where('(node.status = 1 OR (node.status = 4 AND node.uid = ?))', current_user.uid)
    else
      notes = notes.where('node.status = 1')
    end
    notes = notes.to_a # ensure it can be serialized for caching

    # include revisions, then mix with new pages:
    wikis = Node.where(type: 'page', status: 1)
                .order('nid DESC')
                .limit(10)
    revisions = Revision.joins(:node)
                        .order('timestamp DESC')
                        .where('type = (?)', 'page')
                        .where('node.status = 1')
                        .where('node_revisions.status = 1')
                        .where('timestamp - node.created > ?', 300) # don't report edits within 5 mins of page creation
                        .limit(10)
                        .group('node.title')
    # group by day: http://stackoverflow.com/questions/5970938/group-by-day-from-timestamp
    revisions = revisions.group('DATE(FROM_UNIXTIME(timestamp))') if Rails.env == 'production'
    revisions = revisions.to_a # ensure it can be serialized for caching
    wikis += revisions
    wikis = wikis.sort_by(&:created_at).reverse
    comments = Comment.joins(:node, :drupal_users)
                      .order('timestamp DESC')
                      .where('timestamp - node.created > ?', 86_400) # don't report edits within 1 day of page creation
                      .page(params[:page])
                      .group('title') # group by day: http://stackoverflow.com/questions/5970938/group-by-day-from-timestamp
    # group by day: http://stackoverflow.com/questions/5970938/group-by-day-from-timestamp
    comments = comments.group('DATE(FROM_UNIXTIME(timestamp))') if Rails.env == 'production'
    comments = comments.to_a # ensure it can be serialized for caching
    answer_comments = Comment.joins(:answer, :drupal_users)
                             .order('timestamp DESC')
                             .where('timestamp - answers.created_at > ?', 86_400)
                             .limit(20)
                             .group('answers.id')
    answer_comments = answer_comments.group('DATE(FROM_UNIXTIME(timestamp))') if Rails.env == 'production'
    answer_comments = answer_comments.to_a # ensure it can be serialized for caching
    activity = (notes + wikis + comments + answer_comments).sort_by(&:created_at).reverse
    response = [
      activity,
      blog,
      notes,
      wikis,
      revisions,
      comments,
      answer_comments
    ]
    response
  end

end
