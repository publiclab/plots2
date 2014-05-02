class HomeController < ApplicationController

  before_filter :require_user, :only => [:dashboard, :subscriptions, :nearby]

  #caches_action :index, :cache_path => proc { |c|
  #  node = DrupalNode.find :last #c.params[:id]
  #  { :n => node.updated_at.to_i }
  #end

  #caches_action :index, :cache_path => { :last => DrupalNode.find(:last).updated_at.to_i }

  def home
    @title = "a DIY environmental science community"
    redirect_to "/dashboard" if current_user
    render :template => "home/home-alt" if params[:alt]
  end

  # route for seeing the front page even if you are logged in
  def front
    @title = "a community for DIY environmental investigation"
    if params[:alt]
      render :template => "home/home-alt"
    else
      render :template => "home/home"
    end
  end

  def dashboard
    @title = "Dashboard"
    @user = DrupalUsers.find_by_name current_user.username
    @note_count = DrupalNode.count :all, :select => :created, :conditions => {:type => 'note', :status => 1, :created => Time.now.to_i-1.weeks.to_i..Time.now.to_i}
    @wiki_count = DrupalNodeRevision.count :all, :select => :created, :conditions => {:timestamp => Time.now.to_i-1.weeks.to_i..Time.now.to_i}
    set_sidebar
    @unpaginated = true
  end

  def comments
    @comments = DrupalComment.find :all, :limit => 20, :order => "timestamp DESC", :conditions => {:status => 0}
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
      @users = DrupalUsers.find(:all, :conditions => ["lat != 0.0 AND lon != 0.0 AND lat > ? AND lat < ? AND lon > ? AND lon < ?",minlat,maxlat,minlon,maxlon])
    end
  end

end
