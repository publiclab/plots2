require 'rss'

class WikiController < ApplicationController

  before_filter :require_user, :only => [:new, :create, :edit, :update]

  def show
    
    if !(@node = DrupalNode.find_root_by_slug('place/'+params[:id])).nil? # it's a place page!
      place = true
      @tags = [DrupalTag.find_by_name(params[:id])]

    elsif !(@node = DrupalNode.find_root_by_slug('tool/'+params[:id])).nil? # it's a tool page!
      @tags = [DrupalTag.find_by_name(params[:id])]

    elsif !(@node = DrupalNode.find_by_slug(params[:id])).nil? # it's a wiki page
      @tags = @node.tags
      # attempt to add the page name itself as a tag: (not needed, i think)
      #tag = DrupalTag.find_by_name(params[:id])
      #@tags << tag if tag

    else # it's a new wiki page!
      new
    end

    @tagnames = @tags.collect(&:name)
    if place.nil?
      @wikis = DrupalTag.find_nodes_by_type(@tagnames,'page',10)
      @notes = DrupalTag.find_nodes_by_type(@tagnames,'note',10)
      @videos = DrupalTag.find_nodes_by_type_with_all_tags([DrupalTag.find_by_name('video')]+@tags,'note',8)
    end
    @node.view
    @title = @node.title
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

  def new
    flash.now[:notice] = "This page does not exist yet, but you can create it now:"
    title = params[:id].gsub('-',' ')
    @related = DrupalNode.find(:all, :limit => 10, :order => "node.nid DESC", :conditions => ['type = "page" AND status = 1 AND (node.title LIKE ? OR node_revisions.body LIKE ?)', "%"+title+"%","%"+title+"%"], :include => :drupal_node_revision)
    @tags = []
    tag = DrupalTag.find_by_name(params[:id]) # add page name as a tag, too
    @tags << tag if tag

    @related += DrupalTag.find_nodes_by_type(@tags.collect(&:name),'page',10)
    render :template => 'wiki/edit'
  end

  def create
    title = params[:id].downcase.gsub(' ','-').gsub("'",'').gsub('"','')
    title = params[:url].downcase.gsub(' ','-').gsub("'",'').gsub('"','') if params[:url] != ""
    @node = DrupalNode.new({
      :uid => current_user.uid,
      :title => title,
      :type => "page"
    })
    if @node.valid?
      @node.save! 
      @revision = @node.new_revision({
        :nid => @node.id,
        :uid => current_user.uid,
        :title => params[:title],
        :body => params[:body]
      })
      if @revision.valid?
        @revision.save!
        @node.vid = @revision.vid
        @node.save!
        flash[:notice] = "Wiki page created."
        redirect_to @node.path
      else
        @node.destroy # clean up. But do this in the model!
        render :action => :edit
      end
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
      @revision.save
      @node.vid = @revision.vid
      @node.save
      flash[:notice] = "Edits saved."
      redirect_to "/wiki/"+@node.slug
    else
      flash[:error] = "Your edit could not be saved."
      render :action => :edit
      #redirect_to "/wiki/edit/"+@node.slug
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

end
