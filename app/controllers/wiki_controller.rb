require 'rss'

class WikiController < ApplicationController

  before_filter :require_user, :only => [:new, :create, :edit, :update, :delete]

  def show
    if !(@node = DrupalNode.find_by_slug(params[:id])).nil? # it's a place page!
      @tags = @node.tags
      @tags += [DrupalTag.find_by_name(params[:id])] if DrupalTag.find_by_name(params[:id])
    else # it's a new wiki page!
      @title = "New wiki page"
      if current_user
        new
      else
        flash[:warning] = "That page does not yet exist. You must be logged in to create a new wiki page."
        redirect_to "/login"
      end
    end

    unless @title # the page exists
      @tagnames = @tags.collect(&:name)
      set_sidebar :tags, @tagnames, {:videos => true}

      @node.view
      @title = @node.title
    end
  end

  def edit
    @node = DrupalNode.find_by_slug(params[:id])
    # we could do this...
    #@node.locked = true
    #@node.save
    @title = "Editing '"+@node.title+"'"

    @tags = @node.tags
  end

  def new
    @tags = []
    if params[:id]
      flash.now[:notice] = "This page does not exist yet, but you can create it now:" 
      title = params[:id].gsub('-',' ')
      @related = DrupalNode.find(:all, :limit => 10, :order => "node.nid DESC", :conditions => ['type = "page" AND status = 1 AND (node.title LIKE ? OR node_revisions.body LIKE ?)', "%"+title+"%","%"+title+"%"], :include => :drupal_node_revision)
      tag = DrupalTag.find_by_name(params[:id]) # add page name as a tag, too
      @tags << tag if tag
      @related += DrupalTag.find_nodes_by_type(@tags.collect(&:name),'page',10)
    end
    render :template => 'wiki/edit'
  end

  def create
    # we no longer allow custom urls, just titles which are parameterized automatically into urls
    #slug = params[:title].parameterize
    #slug = params[:id].parameterize if params[:id] != "" && !params[:id].nil?
    #slug = params[:url].parameterize if params[:url] != "" && !params[:url].nil?
    saved,@node,@revision = DrupalNode.new_wiki({
      :uid => current_user.uid,
      :title => params[:title],
      :body => params[:body]
    })
    if saved
      flash[:notice] = "Wiki page created."
      redirect_to @node.path
    else
      render :action => :edit
    end
  end

  def update
    @node = DrupalNode.find_by_slug(params[:id])
    @revision = @node.new_revision({
      :nid => @node.id,
      :uid => current_user.uid,
      :title => params[:title],
      :body => params[:body]
    })
    if @revision.valid?
      ActiveRecord::Base.transaction do
        @revision.save
        @node.vid = @revision.vid
        # can't do this because it changes the URL:
        #@node.title = @revision.title
        @node.save
      end
      flash[:notice] = "Edits saved."
      redirect_to "/wiki/"+@node.slug
    else
      flash[:error] = "Your edit could not be saved."
      render :action => :edit
      #redirect_to "/wiki/edit/"+@node.slug
    end
  end

  def delete
    @node = DrupalNode.find(params[:id])
    if current_user.username == "warren"
      @node.transaction do
        @node.destroy
      end
      flash[:notice] = "Wiki page deleted."
      redirect_to "/dashboard"
    else
      flash[:error] = "Only admins can delete wiki pages."
      redirect_to @node.path
    end
  end

  # wiki pages which have a root URL, like http://publiclab.org/about
  def root
    @node = DrupalNode.find_root_by_slug(params[:id])
    @title = @node.title
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

  def index
    @title = "Wiki index"
    @wikis = DrupalNode.find_all_by_type('page',10,:limit => 40,:order => "changed DESC", :conditions => ["status = 1 AND node.nid != 259 AND (type = 'page' OR type = 'tool' OR type = 'place')"])
  end

  def popular
    @title = "Popular wiki pages"
    @wikis = DrupalNode.find(:all, :limit => 40,:order => "node_counter.totalcount DESC", :conditions => ["status = 1 AND node.nid != 259 AND (type = 'page' OR type = 'tool' OR type = 'place')"], :include => :drupal_node_counter)
    render :template => "wiki/index"
  end

  def liked
    @title = "Well-liked wiki pages"
    @wikis = DrupalNode.find(:all, :limit => 40,:order => "node.cached_likes DESC", :conditions => ["status = 1 AND nid != 259 AND (type = 'page' OR type = 'tool' OR type = 'place') AND cached_likes > 0"])
    render :template => "wiki/index"
  end

end
