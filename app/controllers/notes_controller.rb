class NotesController < ApplicationController

  def index
    @title = "Research notes"
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'note', :status => 1}, :page => params[:page], :limit => 20)
    @wikis = DrupalNode.find(:all, :order => "changed DESC", :conditions => {:status => 1, :type => 'page'}, :limit => 10)
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
    @wikis = DrupalTag.find_nodes_by_type(@tagnames,'page',6)
    @notes = DrupalTag.find_nodes_by_type(@tagnames,'note',6)
  end

  def create
    if current_user
      @node = DrupalNode.new({
        :uid => current_user.uid,
        :title => params[:title],
        :type => "note"
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
          # save main image
          if params[:main_image]
            img = Image.find params[:main_image]
            img.nid = @node.id
            img.save
          end
          @node.save!
          # opportunity for moderation
          flash[:notice] = "Research note published."
          redirect_to @node.path
        else
          @node.destroy # clean up. But do this in the model!
          render :template => "editor/post"
        end
      else
        render :template => "editor/post"
      end
    else
      prompt_login "You must be logged in to edit the wiki."
    end
  end

  def edit
    if current_user 
      @node = DrupalNode.find(params[:id],:conditions => {:type => "note"})
      if current_user.uid == @node.uid # || current_user.role == "admin" 
        render :template => "editor/post"
      else
        prompt_login "Only the author can edit a research note."
      end
    else
      prompt_login "You must be logged in to edit."
    end
  end

  # at /notes/update/:id
  def update
    @node = DrupalNode.find(params[:id])
    if current_user && current_user.uid == @node.uid # || current_user.role == "admin" 
      @revision = @node.new_revision({
        :nid => @node.id,
        :uid => current_user.uid,
        :title => params[:title],
        :body => params[:body]
      })
      if @revision.valid?
        @revision.save
        @node.vid = @revision.vid
        # save main image
        if params[:main_image]
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
        #redirect_to "/wiki/edit/"+@node.slug
      end
    else
      prompt_login "You must be logged in to edit."
    end
  end

  # at /notes/delete/:id
  # only for notes
  def delete
    @node = DrupalNode.find(params[:id])
    if current_user && current_user.uid == @node.uid && @node.type == "note" # || current_user.role == "admin" 
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
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'note', :status => 1, :uid => @user.uid}, :page => params[:page])
    render :template => 'notes/index'
  end

  def author_topic
    @user = DrupalUsers.find_by_name params[:author]
    @tagnames = params[:topic].split('+')
    @title = @user.name+" on '"+@tagnames.join(',')+"'"
    @nodes = @user.notes_for_tags(@tagnames)
    @unpaginated = true
    render :template => 'notes/index'
  end

end
