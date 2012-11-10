class MapController < ApplicationController
  def index
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'map', :status => 1}, :page => params[:page])
    render :template => "notes/index"
    #render :text => @nodes.first.inspect
  end

  def show
    @node = DrupalNode.find_map_by_slug(params[:name]+'/'+params[:date])
    @tags = @node.tags
    @tagnames = @tags.collect(&:name)
  end

end
