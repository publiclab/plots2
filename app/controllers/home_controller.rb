class HomeController < ApplicationController
  before_action :require_user, only: %i(subscriptions nearby)

  def home
    if current_user
      redirect_to '/dashboard'
    else
      @projects = Tag.where('term_data.name IN (?)', 'project:featured').first&.nodes
        &.sample(3) # random sampling
      @title = I18n.t('home_controller.science_community')
      render template: 'home/home'
    end
  end

  # route for seeing the front page even if you are logged in
  def front
    @projects = Tag.where('term_data.name IN (?)', 'project:featured').first&.nodes
      &.sample(3) # random sampling
    @title = I18n.t('home_controller.environmental_investigation')
    render template: 'home/home'
    @unpaginated = true
  end

  # used in front and home methods only
  def blog
    @notes = Node.where(status: 1, type: 'note')
      .includes(:revision, :tag)
      .references(:term_data, :node_revisions)
      .where('term_data.name = ?', 'blog')
      .order('created DESC')
      .paginate(page: params[:page], per_page: 8)
  end

  def dashboard
    if current_user
      @note_count = Node.select(%i(created type status))
        .where(type: 'note', status: 1, created: Time.now.to_i - 1.weeks.to_i..Time.now.to_i)
        .count(:all)
      @wiki_count = Revision.select(:timestamp)
        .where(timestamp: Time.now.to_i - 1.weeks.to_i..Time.now.to_i)
        .count
      @user_note_count = Node.where(type: 'note', status: 1, uid: current_user.uid).count
      @activity, @blog, @notes, @wikis, @revisions, @comments, @answer_comments = activity
      render template: 'dashboard/dashboard'
    else
      redirect_to '/research'
    end
  end

  def research
    if current_user
      redirect_to '/dashboard'
    else
      @note_count = Node.select(%i(created type status))
        .where(type: 'note', status: 1, created: Time.now.to_i - 1.weeks.to_i..Time.now.to_i)
        .count(:all)
      @wiki_count = Revision.select(:timestamp)
        .where(timestamp: Time.now.to_i - 1.weeks.to_i..Time.now.to_i)
        .count
      @activity, @blog, @notes, @wikis, @revisions, @comments, @answer_comments = activity
      render template: 'dashboard/dashboard'
      @title = I18n.t('home_controller.community_research')
    end
  end

  private

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

    comments = Comment.joins(:node, :user)
                   .order('timestamp DESC')
                   .where('timestamp - node.created > ?', 86_400) # don't report edits within 1 day of page creation
                   .where('node.status = ?', 1)
                   .page(params[:page])
                   .group(['title', 'comments.cid']) # ONLY_FULL_GROUP_BY, issue #3120

    if logged_in_as(['admin', 'moderator'])
      notes = notes.where('(node.status = 1 OR node.status = 3)')
      comments = comments.where('comments.status = 1')
    elsif current_user
      coauthor_nids = Node.joins(:node_tag)
        .joins('LEFT OUTER JOIN term_data ON term_data.tid = community_tags.tid')
        .select('node.*, term_data.*, community_tags.*')
        .where(type: 'note', status: 3)
        .where('term_data.name = (?)', "with:#{current_user.username}")
        .collect(&:nid)
      notes = notes.where('(node.nid IN (?) OR node.status = 1 OR ((node.status = 3 OR node.status = 4) AND node.uid = ?))', coauthor_nids, current_user.uid)
      comments = comments.where('comments.status = 1 OR (comments.status = 4 AND comments.uid = ?)', current_user.uid)
    else
      notes = notes.where('node.status = 1')
      comments = comments.where('comments.status = 1')
    end

    notes = notes.to_a # ensure it can be serialized for caching

    # include revisions, then mix with new pages:
    wikis = Node.where(type: 'page', status: 1)
      .order('nid DESC')
      .limit(10)
    revisions = Revision.joins(:node)
      .includes(:node)
      .order('timestamp DESC')
      .where('type = (?)', 'page')
      .where('node.status = 1')
      .where('node_revisions.status = 1')
      .where('timestamp - node.created > ?', 300) # don't report edits within 5 mins of page creation
      .limit(10)
      .group(['node.title', 'node.nid', 'node_revisions.vid']) # ONLY_FULL_GROUP_BY, issue #3120
    # group by day: http://stackoverflow.com/questions/5970938/group-by-day-from-timestamp
    revisions = revisions.group('DATE(FROM_UNIXTIME(timestamp))') if Rails.env == 'production'
    revisions = revisions.to_a # ensure it can be serialized for caching
    wikis += revisions
    wikis = wikis.sort_by(&:created_at).reverse

    # group by day: http://stackoverflow.com/questions/5970938/group-by-day-from-timestamp
    comments = comments.group('DATE(FROM_UNIXTIME(timestamp))') if Rails.env == 'production'
    comments = comments.to_a # ensure it can be serialized for caching
    answer_comments = Comment.joins(:answer, :user)
      .order('timestamp DESC')
      .where('timestamp - answers.created_at > ?', 86_400)
      .limit(20)
      .group(['answers.id', 'comments.cid']) # ONLY_FULL_GROUP_BY, issue #3120
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
