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
    @notes = DrupalNode.where(type: 'note', status: 1)
                       .page(params[:page])
    @wikis = DrupalNode.where(type: 'page', status: 1)
                       .page(params[:page])
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
