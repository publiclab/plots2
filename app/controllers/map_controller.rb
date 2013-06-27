class MapController < ApplicationController

  def index
    @title = "Maps"
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'map', :status => 1}, :page => params[:page])
    @maps = DrupalNode.find(:all, :order => "nid DESC", :conditions => {:type => 'map', :status => 1})
  end

  def show
    @node = DrupalNode.find_map_by_slug(params[:name]+'/'+params[:date])
    @node.view
    @title = @node.title
    @tags = @node.tags
    @tagnames = @tags.collect(&:name)

    set_sidebar :tags, @tagnames
  end

  def tag
    set_sidebar :tags, [params[:id]], {:note_count => 20}

    @tagnames = params[:id].split(',')
    nids = DrupalTag.find_nodes_by_type(params[:id],'map',20).collect(&:nid)
    @notes = DrupalNode.paginate(:conditions => ['nid in (?)', nids], :order => "nid DESC", :page => params[:page])

    @title = @tagnames.join(', ') if @tagnames
    @unpaginated = true
    render :template => 'tag/show'
  end

end
