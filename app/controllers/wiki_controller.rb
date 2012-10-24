class WikiController < ApplicationController

  def show
    @tags = ['balloon-mapping','somerville']
    @node = DrupalNode.find_by_slug(params[:id])
    @revision = @node.latest
  end

  def revisions
    @tags = ['balloon-mapping','somerville']
    @node = DrupalNode.find_by_slug(params[:id])
  end

  def revision
    @tags = ['balloon-mapping','somerville']
    @node = DrupalNode.find_by_slug(params[:id])
    @revision = DrupalNodeRevision.find_by_vid(params[:vid])
    render :template => "wiki/show"
  end

end
