class NotesController < ApplicationController

  respond_to :html
  before_filter :require_user, :only => [:create, :edit, :update, :delete, :rsvp]

  def index
    @title = "Research notes"
    set_sidebar
  end

  def tools
    @title = "Tools"
    @notes = DrupalNode.where(status: 1, type: ['page','tool'])
                       .includes(:drupal_node_revision, :drupal_tag)
                       .where('term_data.name = ?','tool')
                       .page(params[:page])
                       .order("node_revisions.timestamp DESC")
    render :template => "notes/tools_places"
  end

  def places
    @title = "Places"
    @notes = DrupalNode.where(status: 1, type: ['page','place'])
                       .includes(:drupal_node_revision, :drupal_tag)
                       .where('term_data.name = ?','chapter')
                       .page(params[:page])
                       .order("node_revisions.timestamp DESC")
    render :template => "notes/tools_places"
  end

  def shortlink
    @node = DrupalNode.find params[:id]
    redirect_to @node.path
  end

  # display a revision, raw
  def raw
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    render :text => DrupalNode.find(params[:id]).latest.body
  end

  def show
    if params[:author] && params[:date]
      @node = DrupalNode.where(path: "/notes/#{params[:author]}/#{params[:date]}/#{params[:id]}").first
      @node = @node || DrupalNode.where(path: "/report/#{params[:id]}").first
    else
      @node = DrupalNode.find params[:id]
    end

    return if check_and_redirect_node(@node)

    if @node.author.status == 0 && !(current_user && (current_user.role == "admin" || current_user.role == "moderator"))
      flash[:error] = "The author of that note has been banned."
      redirect_to "/"
    elsif @node.status != 1 && !(current_user && (current_user.role == "admin" || current_user.role == "moderator"))
      # if it's spam or a draft
      # no notification; don't let people easily fish for existing draft titles; we should try to 404 it
      redirect_to "/"
    end
 
    @node.view
    @title = @node.latest.title
    @tags = @node.tags
    @tagnames = @tags.collect(&:name)

    set_sidebar :tags, @tagnames
  end

  def image
    params[:size] = params[:size] || :large
    redirect_to DrupalNode.find(params[:id]).main_image.path(params[:size])
  end

  def create
    if current_user.drupal_user.status == 1
      saved,@node,@revision = DrupalNode.new_note({
        :uid => current_user.uid,
        :title => params[:title],
        :body => params[:body],
        :main_image => params[:main_image]
      })

      if saved
        if params[:tags]
          params[:tags].gsub(' ',',').split(',').each do |tagname|
            @node.add_tag(tagname.strip,current_user)
          end
        end
        if params[:event] == "on"
          @node.add_tag("event",current_user)
          @node.add_tag("event:rsvp",current_user)
          @node.add_tag("date:"+params[:date],current_user) if params[:date]
        end
        # trigger subscription notifications:
        SubscriptionMailer.notify_node_creation(@node)
        # opportunity for moderation
        flash[:notice] = "Research note published. Get the word out on <a href='/lists'>the discussion lists</a>!"
        redirect_to @node.path
      else
        render :template => "editor/post"
      end
    else
      flash.keep[:error] = "You have been banned. Please contact <a href='mailto:web@publiclab.org'>web@publiclab.org</a> if you believe this is in error."
      redirect_to "/logout"
    end
  end

  def edit
    @node = DrupalNode.find(params[:id],:conditions => {:type => "note"})
    if current_user.uid == @node.uid || current_user.role == "admin" 
      render :template => "editor/post"
    else
      prompt_login "Only the author can edit a research note."
    end
  end

  # at /notes/update/:id
  def update
    @node = DrupalNode.find(params[:id])
    if current_user.uid == @node.uid || current_user.role == "admin" 
      @revision = @node.latest
      @revision.title = params[:title]
      @revision.body = params[:body]
      if params[:tags]
        params[:tags].gsub(' ',',').split(',').each do |tagname|
          @node.add_tag(tagname,current_user)
        end
      end
      if @revision.valid?
        @revision.save
        @node.vid = @revision.vid
        # update vid (version id) of main image
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
          unless img.nil?
            img.nid = @node.id
            img.save
          end
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
    if current_user.uid == @node.uid && @node.type == "note" || current_user.role == "admin" || current_user.role == "moderator"
      @node.delete
      respond_with do |format|
        format.html do
          if request.xhr?
            render :text => "Content deleted."
          else
            flash[:notice] = "Content deleted."
            redirect_to "/dashboard"
          end
        end
      end
    else
      prompt_login
    end
  end

  # notes for a given author
  def author
    @user = DrupalUsers.find_by_name params[:id]
    @title = @user.name
    @notes = DrupalNode.page(params[:page])
                       .order("nid DESC")
                       .where(type: 'note', status: 1, uid: @user.uid)
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

  # notes with high # of likes
  def liked
    @title = "Highly liked research notes"
    @wikis = DrupalNode.limit(10)
                       .where(type: 'page', status: 1)
                       .order("nid DESC")
    @notes = DrupalNode.limit(20)
                       .order("cached_likes DESC")
                       .where(type: 'note', status: 1)
    @unpaginated = true
    render :template => 'notes/index'
  end

  # notes with high # of views
  def popular
    @title = "Popular research notes"
    @wikis = DrupalNode.limit(10)
                       .where(type: 'page', status: 1)
                       .order("nid DESC")
    @notes = DrupalNode.limit(20)
                       .order("node_counter.totalcount DESC")
                       .where(type: 'note', status: 1)
                       .includes(:drupal_node_counter)
    @unpaginated = true
    render :template => 'notes/index'
  end

  def rss
    @notes = DrupalNode.limit(20)
                       .order("nid DESC")
                       .where("type = ? AND status = 1 AND created < ?", 'note', (Time.now.to_i - 30.minutes.to_i))
    respond_to do |format|
      format.rss {
        render :layout => false
        response.headers["Content-Type"] = "application/xml; charset=utf-8"
      } 
    end
  end

  def liked_rss
    @notes = DrupalNode.limit(20)
                       .order("created DESC")
                       .where('type = ? AND status = 1 AND cached_likes > 0', 'note')
    respond_to do |format|
      format.rss {
        render :layout => false, :template => "notes/rss"
        response.headers["Content-Type"] = "application/xml; charset=utf-8"
      } 
    end
  end

  def rsvp
    @node = DrupalNode.find params[:id]
    # leave a comment
    @comment = @node.add_comment({:subject => 'rsvp', :uid => current_user.uid,:body => 
      "I will be attending!"
    })
    # make a tag
    @node.add_tag("rsvp:"+current_user.username,current_user)
    redirect_to @node.path+"#comments"
  end

end
