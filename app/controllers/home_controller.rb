class HomeController < ApplicationController

  before_filter :require_user, :only => [:subscriptions, :nearby]

  #caches_action :index, :cache_path => proc { |c|
  #  node = DrupalNode.find :last #c.params[:id]
  #  { :n => node.updated_at.to_i }
  #end

  #caches_action :index, :cache_path => { :last => DrupalNode.find(:last).updated_at.to_i }

  def home
    @title = "a DIY environmental science community"
    if current_user
      redirect_to "/dashboard"
    else
      render :template => "home/home"
    end
  end

  # proxy to enable AJAX loading of RSS feeds, which requires same-origin
  def fetch
    if true #Rails.env.production?
      if params[:url][0..24] == "https://groups.google.com" || params[:url] == "https://feeds.feedburner.com/rssmixer/ZvcX"
        url = URI.parse(params[:url])
        result = Net::HTTP.get_response(url)
        send_data result.body, :type => result.content_type, :disposition => 'inline'
      end
    else
      redirect_to params[:url]
    end
  end

  # route for seeing the front page even if you are logged in
  def front
    @title = "a community for DIY environmental investigation"
    render :template => "home/home"
  end

  def dashboard2
    redirect_to '/dashboard'
  end

  def dashboard
    @note_count = DrupalNode.select([:created, :type, :status])
                            .where(type: 'note', status: 1, created: Time.now.to_i - 1.weeks.to_i..Time.now.to_i)
                            .count
    @wiki_count = DrupalNodeRevision.select(:timestamp)
                                    .where(timestamp: Time.now.to_i - 1.weeks.to_i..Time.now.to_i)
                                    .count
    @blog = DrupalTag.find_nodes_by_type('blog', 'note', 1).first
    # remove "classroom" postings; also switch to an EXCEPT operator in sql, see https://github.com/publiclab/plots2/issues/375
    hidden_nids = DrupalNode.joins(:drupal_node_community_tag)
                            .joins("LEFT OUTER JOIN term_data ON term_data.tid = community_tags.tid")
                            .select('node.*, term_data.*, community_tags.*')
                            .where(type: 'note', status: 1)
                            .where('term_data.name = (?)', 'hidden:response')
                            .collect(&:nid)
    @notes = DrupalNode.where(type: 'note')
                       .where('node.nid NOT IN (?)', hidden_nids + [0]) # in case hidden_nids is empty
                       .order('nid DESC')
                       .page(params[:page])
    @notes = @notes.where('nid != (?)', @blog.nid) if @blog

    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      @notes = @notes.where('(node.status = 1 OR node.status = 4)')
    elsif current_user
      @notes = @notes.where('(node.status = 1 OR (node.status = 4 AND node.uid = ?))', current_user.uid)
    else
      @notes = @notes.where('node.status = 1')
    end

    # include revisions, then mix with new pages:
    @wikis = DrupalNode.where(type: 'page', status: 1)
                       .order('nid DESC')
                       .limit(10)
    revisions = DrupalNodeRevision.joins(:drupal_node)
                                .order('timestamp DESC')
                                .where('type = (?)', 'page')
                                .where('node.status = 1')
                                .where('timestamp - node.created > ?', 300) # don't report edits within 5 mins of page creation
                                .limit(10)
                                .group('node.title')
    # group by day: http://stackoverflow.com/questions/5970938/group-by-day-from-timestamp
    revisions = revisions.group('DATE(FROM_UNIXTIME(timestamp))') if Rails.env == "production"
    @wikis = @wikis + revisions
    @wikis = @wikis.sort_by { |a| a.created_at }.reverse
    @comments = DrupalComment.joins(:drupal_node, :drupal_users)
                             .order('timestamp DESC')
                             .where('timestamp - node.created > ?', 86400) # don't report edits within 1 day of page creation
                             .limit(20)
                             .group('title') # group by day: http://stackoverflow.com/questions/5970938/group-by-day-from-timestamp
#                            .where('comments.status = (?)', 1)
    # group by day: http://stackoverflow.com/questions/5970938/group-by-day-from-timestamp
    @comments = @comments.group('DATE(FROM_UNIXTIME(timestamp))') if Rails.env == "production"
    @activity = (@notes + @wikis + @comments).sort_by { |a| a.created_at }.reverse
    @user_note_count = DrupalNode.where(type: 'note', status: 1, uid: current_user.uid).count if current_user
    render template: 'dashboard/dashboard'
    @title = "Community research" unless current_user
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
      @users = DrupalUsers.where("lat != 0.0 AND lon != 0.0 AND lat > ? AND lat < ? AND lon > ? AND lon < ?", minlat, maxlat, minlon, maxlon)
    end
  end

end
