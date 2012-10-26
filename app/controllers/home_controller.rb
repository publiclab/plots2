class HomeController < ApplicationController

  def index
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'note', :status => 1}, :page => params[:page])
  end

end
