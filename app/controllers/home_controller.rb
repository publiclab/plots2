class HomeController < ApplicationController

  #caches_action :index, :cache_path => proc { |c|
  #  node = DrupalNode.find :last #c.params[:id]
  #  { :n => node.updated_at.to_i }
  #end

  #caches_action :index, :cache_path => { :last => DrupalNode.find(:last).updated_at.to_i }

  def front
    @title = "Home"
  end

  def dashboard
    if current_user
      @title = "Dashboard"
      @user = DrupalUsers.find_by_name current_user.username
      @wikis = DrupalTag.find_nodes_by_type(@user.tagnames,'page',10)
      @nodes = DrupalTag.find_nodes_by_type(@user.tagnames,'note',8)
      @unpaginated = true
    else
      prompt_login "You must be logged in to see the dashboard."
    end
  end

  def nearby
  end

  def people
    redirect_to "/profile/"+params[:id]
  end

  def subscriptions
    @title = "Subscriptions"
    @user = DrupalUsers.find_by_name(params[:id])
  end

  # trashy... clean this up!
  def nearby
    dist = 1.5
    current_user = current_user
    if current_user && current_user.lat
      minlat = current_user.lat - dist
      maxlat = current_user.lat + dist
      minlon = current_user.lon - dist
      maxlon = current_user.lon + dist
      @users = DrupalUsers.find(:all, :conditions => ["lat != 0.0 AND lon != 0.0 AND lat > ? AND lat < ? AND lon > ? AND lon < ?",minlat,maxlat,minlon,maxlon])
    end
  end

end
