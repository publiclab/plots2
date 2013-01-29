class WikiController < ApplicationController

  def show
    @node = DrupalNode.find_by_slug(params[:id])
    if @node
      @title = @node.title
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
    #elsif !logged_in?
      #render :template => 'notloggedin'
    else
      title = params[:id].gsub('-',' ')
      @related = DrupalNode.find(:all, :limit => 10, :order => "node.nid DESC", :conditions => ['type = "page" AND status = 1 AND (node.title LIKE ? OR node_revisions.body LIKE ?)', "%"+title+"%","%"+title+"%"], :include => :drupal_node_revision)
      @tags = []
      tag = DrupalTag.find_by_name(params[:id])
      @tags << tag if tag
      title.split(' ').each do |t|
        tag = DrupalTag.find_by_name(t)
        @tags << tag if tag
      end
      @related += DrupalTag.find_nodes_by_type(@tags,'page',10)
      flash[:notice] = "This page does not exist yet, but you can create it now:"
      render :template => 'wiki/edit'
    end
  end

  def edit
    @node = DrupalNode.find_by_slug(params[:id])
    @title = "Editing '"+@node.title+"'"
    if @node.nil?
      @node = DrupalNode.find_root_by_slug('place/'+params[:id]) 
      @place = true if @node.nil?
    end
    @tags = @node.tags
  end

  def root
    @node = DrupalNode.find_root_by_slug(params[:id])
    @revision = @node.latest
    @tags = @node.tags
    @tagnames = @tags.collect(&:name)
    render :template => "wiki/show"
  end

  def revisions
    @node = DrupalNode.find_by_slug(params[:id])
    @title = "Revisions for '"+@node.title+"'"
    @tags = @node.tags
  end

  def revision
    @node = DrupalNode.find_by_slug(params[:id])
    @title = "Revision for '"+@node.title+"'"
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
