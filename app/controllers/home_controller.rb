class HomeController < ApplicationController

  before_filter :require_user, :only => [:dashboard, :subscriptions, :nearby]

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

  # route for seeing the front page even if you are logged in
  def front
    @title = "a community for DIY environmental investigation"
    render :template => "home/home"
  end

  def dashboard
    @title = "Dashboard"
    @user = DrupalUsers.find_by_name current_user.username
    @note_count = DrupalNode.select([:created, :type, :status])
                            .where(type: 'note', status: 1, created: Time.now.to_i - 1.weeks.to_i..Time.now.to_i)
                            .count
    @wiki_count = DrupalNodeRevision.select(:timestamp)
                                    .where(timestamp: Time.now.to_i - 1.weeks.to_i..Time.now.to_i)
                                    .count
    set_sidebar
    @unpaginated = true
  end

  def dashboard2
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
    @notes = DrupalNode.where(type: 'note', status: 1)
                       .where('nid != (?)', @blog.nid)
                       .where('node.nid NOT IN (?)', hidden_nids)
                       .order('nid DESC')
                       .page(params[:page])
    # include revisions, then mix with new pages:
    @wikis = DrupalNode.where(type: 'page', status: 1)
                       .order('nid DESC')
                       .limit(10)
    @wikis += DrupalNodeRevision.joins(:drupal_node)
                                .order('timestamp DESC')
                                .where('type = (?)', 'page')
                                .where('status = (?)', 1)
                                .where('timestamp - node.created > ?', 300) # don't report edits within 5 mins of page creation
                                .limit(10)
                                .group(:title, 'DATE(FROM_UNIXTIME(timestamp))') # group by day: http://stackoverflow.com/questions/5970938/group-by-day-from-timestamp
    @wikis = @wikis.sort_by { |a| a.created_at }.reverse
    @comments = DrupalComment.joins(:drupal_node, :drupal_users)
                             .order('timestamp DESC')
                             .where('timestamp - node.created > ?', 86400) # don't report edits within 1 day of page creation
                             .limit(20)
                             .group('title', 'DATE(FROM_UNIXTIME(timestamp))') # group by day: http://stackoverflow.com/questions/5970938/group-by-day-from-timestamp
#                            .where('comments.status = (?)', 1)
    @activity = (@notes + @wikis + @comments).sort_by { |a| a.created_at }.reverse
    @user_note_count = DrupalNode.where(type: 'note', status: 1, uid: current_user.uid).count
    render template: 'dashboard/dashboard'
  end

  def comments
    @comments = DrupalComment.limit(20)
                             .order("timestamp DESC")
                             .where(status: 0)
    render :partial => "home/comments"
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
