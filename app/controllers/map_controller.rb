class MapController < ApplicationController
  def index
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'map', :status => 1}, :page => params[:page])
    render :template => "notes/index"
    #render :text => @nodes.first.inspect
  end
end
