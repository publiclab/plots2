class WikiController < ApplicationController

  def show
    @node = DrupalNode.find_by_slug(params[:id])
    @tags = @node.tags
    @tagnames = @tags.collect(&:name)
    @revision = @node.latest
    @wikis = DrupalTag.find_nodes_by_type(@tags,'page',10)
    @notes = DrupalTag.find_nodes_by_type(@tags,'note',10)
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

end
