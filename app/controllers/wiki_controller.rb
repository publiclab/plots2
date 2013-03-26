class WikiController < ApplicationController

  def show
    @node = DrupalNode.find_by_slug(params[:id])
    if @node # it's a wiki page
      @title = @node.title
       @tags = @node.tags
       @tagnames = @tags.collect(&:name)
       # attempt to add the page name itself as a tag:
         tag = DrupalTag.find_by_name(params[:id])
         @tags << tag if tag
       @node.view
       @wikis = DrupalTag.find_nodes_by_type(@tagnames,'page',10)
       @notes = DrupalTag.find_nodes_by_type(@tagnames,'note',10)
       @videos = DrupalTag.find_nodes_by_type_with_all_tags([DrupalTag.find_by_name('video')]+@tags,'note',8)
    else # its not a regular wiki page
      @node = DrupalNode.find_root_by_slug('place/'+params[:id]) 
      if @node.nil? # it's not a place page either! new wiki page!
        title = params[:id].gsub('-',' ')
        @related = DrupalNode.find(:all, :limit => 10, :order => "node.nid DESC", :conditions => ['type = "page" AND status = 1 AND (node.title LIKE ? OR node_revisions.body LIKE ?)', "%"+title+"%","%"+title+"%"], :include => :drupal_node_revision)
        @tags = []
        tag = DrupalTag.find_by_name(params[:id])
        @tags << tag if tag
        title.split(' ').each do |t|
          tag = DrupalTag.find_by_name(t)
          @tags << tag if tag
        end
        @tagnames = @tags.collect(&:name)
        @related += DrupalTag.find_nodes_by_type(@tagnames,'page',10)
        flash[:notice] = "This page does not exist yet, but you can create it now:"
        render :template => 'wiki/edit'
      else # it's a place page!
        @place = true
        @tags = [DrupalTag.find_by_name(params[:id])]
      end
    end
  end

  def place

  end

  def tool

  end

  def edit
    @node = DrupalNode.find_by_slug(params[:id])
    # we could do this...
    #@node.locked = true
    #@node.save
    @title = "Editing '"+@node.title+"'"
    if @node.nil?
      @node = DrupalNode.find_root_by_slug('place/'+params[:id]) 
      @place = true if @node.nil?
    end
    @tags = @node.tags
  end

  def update
    if current_user && current_user.username == "warren"
      @node = DrupalNode.find_by_slug(params[:id])
      @revision = @node.new_revision({
        :nid => @node.id,
        :uid => current_user.uid,
        :title => params[:title],
        :body => params[:body]
      })
      if @revision.save
        flash[:notice] = "Edits saved."
        redirect_to "/wiki/"+@node.slug
      else
        flash[:error] = "Your edit could not be saved."
      end
    else
      prompt_login "You must be logged in to edit."
    end
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
