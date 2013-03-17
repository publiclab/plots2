class HomeController < ApplicationController

  def index
    @title = "Home"
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'note', :status => 1}, :page => params[:page])
  end

  def dashboard
    if current_user
      @title = "Dashboard"
      @user = DrupalUsers.find_by_name "warren" 
      @tags = @user.tags

      @wikis = DrupalTag.find_nodes_by_type(@tags,'page',10)
      @nodes = DrupalTag.find_nodes_by_type(@tags,'note',8)
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

  def profile
    @user = DrupalUsers.find_by_name(params[:id])
    @title = @user.name
  end

  def subscriptions
    @title = "Subscriptions"
    @user = DrupalUsers.find_by_name(params[:id])
  end

  # trashy... clean this up!
  def nearby
    dist = 1.5
    @current_user = DrupalUsers.find_by_name(params[:login])
    if @current_user && @current_user.lat
      minlat = @current_user.lat - dist
      maxlat = @current_user.lat + dist
      minlon = @current_user.lon - dist
      maxlon = @current_user.lon + dist
      @users = DrupalUsers.find(:all, :conditions => ["lat != 0.0 AND lon != 0.0 AND lat > ? AND lat < ? AND lon > ? AND lon < ?",minlat,maxlat,minlon,maxlon])
    elsif params[:q]
      result = Geokit::Geocoders::MultiGeocoder.geocode(params[:q])
      minlat = result.lat - dist
      maxlat = result.lat + dist
      minlon = result.lng - dist
      maxlon = result.lng + dist
      @current_user = DrupalUsers.new()
      @current_user.lat = result.lat
      @current_user.lon = result.lng
      @users = DrupalUsers.find(:all, :conditions => ["lat != 0.0 AND lon != 0.0 AND lat > ? AND lat < ? AND lon > ? AND lon < ?",minlat,maxlat,minlon,maxlon])
    else
    end
  end

end
