class HomeController < ApplicationController

  def index
    @title = "Home"
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'note', :status => 1}, :page => params[:page])
  end

  def dashboard
    @title = "Dashboard"
    @user = DrupalUsers.find_by_name "warren" 
    @tags = []
    ['balloon-mapping','leaffest','spectrometer'].each do |tagname|
      @tags << DrupalTag.find_by_name(tagname)
    end
    users = ['donblair','cfastie','liz']

    @wikis = DrupalTag.find_nodes_by_type(@tags,'page',10)
    @nodes = DrupalTag.find_nodes_by_type(@tags,'note',8)
    @unpaginated = true
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

end
