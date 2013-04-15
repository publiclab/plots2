class NotesController < ApplicationController

  before_filter :require_user, :only => [:create, :edit, :update]

  def index
    @title = "Research notes"
    set_sidebar
  end

  def show
    if params[:author] && params[:date]
      @node = DrupalUrlAlias.find_by_dst('notes/'+params[:author]+'/'+params[:date]+'/'+params[:id]).node 
    else
      @node = DrupalNode.find params[:id]
    end
    @node.view
    @title = @node.title
    @tags = @node.tags
    @tagnames = @tags.collect(&:name)

    set_sidebar :tags, @tagnames
  end

  def create
    saved,@node,@revision = DrupalNode.new_note({
      :uid => current_user.uid,
      :title => params[:title],
      :body => params[:body],
      :main_image => params[:main_image]
    })
    if saved
      params[:tags].split(',').each do |tagname|
        @node.add_tag(tagname,current_user)
      end
      # opportunity for moderation
      flash[:notice] = "Research note published."
      redirect_to @node.path
    else
      render :template => "editor/post"
    end
  end

  def edit
    @node = DrupalNode.find(params[:id],:conditions => {:type => "note"})
    if current_user.uid == @node.uid || current_user.username == "warren" # || current_user.role == "admin" 
      render :template => "editor/post"
    else
      prompt_login "Only the author can edit a research note."
    end
  end

  # at /notes/update/:id
  def update
    @node = DrupalNode.find(params[:id])
    if current_user.uid == @node.uid || current_user.username == "warren" # || current_user.role == "admin" 
      @revision = @node.latest
      @revision.title = params[:title]
      @revision.body = params[:body]
      if @revision.valid?
        @revision.save
        @node.vid = @revision.vid
        if @node.drupal_main_image
          i = @node.drupal_main_image
          i.vid = @revision.vid 
          i.save
        end
        @node.drupal_content_field_image_gallery.each do |img|
          img.vid = @revision.vid
          img.save
        end
        @node.title = @revision.title
        # save main image
        if params[:main_image] && params[:main_image] != ""
          img = Image.find params[:main_image]
          img.nid = @node.id
          img.save
        end
        @node.save!
        flash[:notice] = "Edits saved."
        redirect_to @node.path
      else
        flash[:error] = "Your edit could not be saved."
        render :action => :edit
      end
    end
  end

  # at /notes/delete/:id
  # only for notes
  def delete
    @node = DrupalNode.find(params[:id])
    if current_user.uid == @node.uid && @node.type == "note" # || current_user.role == "admin" 
      @node.delete
      flash[:notice] = "Content deleted."
      redirect_to "/dashboard"
    else
      prompt_login
    end
  end

  def author
    @user = DrupalUsers.find_by_name params[:id]
    @title = @user.name
    @notes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'note', :status => 1, :uid => @user.uid}, :page => params[:page])
    render :template => 'notes/index'
  end

  # notes for given comma-delimited tags params[:topic] for author
  def author_topic
    @user = DrupalUsers.find_by_name params[:author]
    @tagnames = params[:topic].split('+')
    @title = @user.name+" on '"+@tagnames.join(', ')+"'"
    @notes = @user.notes_for_tags(@tagnames)
    @unpaginated = true
    render :template => 'notes/index'
  end

end
