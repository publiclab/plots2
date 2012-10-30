class WikiController < ApplicationController

  def show
    @node = DrupalNode.find_by_slug(params[:id])
    if @node.nil?
      @node = DrupalNode.find_root_by_slug('place/'+params[:id]) 
      @place = true
      @tags = [DrupalTag.find_by_name(params[:id])]
    else
      @tags = @node.tags
    end
    # attempt to add the page name itself as a tag:
      tag = DrupalTag.find_by_name(params[:id])
      @tags << tag if tag
    @tagnames = @tags.collect(&:name)
    @revision = @node.latest
    @wikis = DrupalTag.find_nodes_by_type(@tags,'page',10)
    @notes = DrupalTag.find_nodes_by_type(@tags,'note',10)
    @videos = DrupalTag.find_nodes_by_type_with_all_tags([DrupalTag.find_by_name('video')]+@tags,'note',8)
  end

  def edit
    @node = DrupalNode.find_by_slug(params[:id])
    if @node.nil?
      @node = DrupalNode.find_root_by_slug('place/'+params[:id]) 
      @place = true
    end
    @tags = @node.tags
  end

  def root
    @node = DrupalNode.find_root_by_slug(params[:id])
    @revision = @node.latest
    render :template => "wiki/show"
  end

  def revisions
    @node = DrupalNode.find_by_slug(params[:id])
    @tags = @node.tags
  end

  def revision
    @node = DrupalNode.find_by_slug(params[:id])
    @tags = @node.tags
    @revision = DrupalNodeRevision.find_by_vid(params[:vid])
    render :template => "wiki/show"
  end

  def tags
    @tags = []
    params[:tags].split('+').each do |tagname|
      @tags << DrupalTag.find_by_name(tagname)
    end
    @tagnames = @tags.collect(&:name)
    @notes = DrupalTag.find_nodes_by_type(@tags,'note',10)
    @wikis = DrupalTag.find_nodes_by_type(@tags,'page',10)
    render :template => 'wiki/index'
  end

  def place
    redirect_to "/wiki/"+params[:id]
  end

  def tool
    redirect_to "/wiki/"+params[:id]
  end

end
