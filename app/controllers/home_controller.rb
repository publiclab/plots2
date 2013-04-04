class HomeController < ApplicationController

  before_filter :require_user, :only => [:dashboard, :subscriptions, :nearby]

  #caches_action :index, :cache_path => proc { |c|
  #  node = DrupalNode.find :last #c.params[:id]
  #  { :n => node.updated_at.to_i }
  #end

  #caches_action :index, :cache_path => { :last => DrupalNode.find(:last).updated_at.to_i }

  def dashboard
    @title = "Dashboard"
    @user = DrupalUsers.find_by_name current_user.username
    set_sidebar :tags, @user.tagnames
    @unpaginated = true
  end

  def subscriptions
    @title = "Subscriptions"
    @user = DrupalUsers.find_by_name(params[:id])
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
