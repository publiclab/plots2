class MapController < ApplicationController

  def index
    @title = "Maps"
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'map', :status => 1}, :page => params[:page])
    @maps = DrupalNode.find(:all, :order => "nid DESC", :conditions => {:type => 'map', :status => 1})
  end

  def show
    @node = DrupalNode.find_map_by_slug(params[:name]+'/'+params[:date])
    @title = @node.title
    @tags = @node.tags
    @tagnames = @tags.collect(&:name)
  end

end
