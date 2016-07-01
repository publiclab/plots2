include ActionView::Helpers::DateHelper # required for time_ago_in_words()
class NotesController < ApplicationController

  respond_to :html
  before_filter :require_user, :only => [:create, :edit, :update, :delete, :rsvp]

  def index
    @title = "Research notes"
    set_sidebar
  end

  def stats
    if params[:time]
      @time = Time.parse(params[:time])
    else
      @time = Time.now
    end

    @weekly_notes = DrupalNode.select([:created, :type, :status])
                              .where(type: 'note', status: 1, created: @time.to_i - 1.weeks.to_i..@time.to_i)
                              .count
    @weekly_wikis = DrupalNodeRevision.select(:timestamp)
                                      .where(timestamp: @time.to_i - 1.weeks.to_i..@time.to_i)
                                      .count
    @weekly_members = User.where(created_at: @time - 1.weeks..@time)
                          .count
    @monthly_notes = DrupalNode.select([:created, :type, :status])
                               .where(type: 'note', status: 1, created: @time.to_i - 1.months.to_i..@time.to_i)
                               .count
    @monthly_wikis = DrupalNodeRevision.select(:timestamp)
                                       .where(timestamp: @time.to_i - 1.months.to_i..@time.to_i)
                                       .count
    @monthly_members = User.where(created_at: @time - 1.months..@time)
                           .count

    @notes_per_week_past_year = DrupalNode.select([:created, :type, :status])
                                          .where(type: 'note', status: 1, created: @time.to_i - 1.years.to_i..@time.to_i)
                                          .count / 52.0
    @edits_per_week_past_year = DrupalNodeRevision.select(:timestamp)
                                                  .where(timestamp: @time.to_i - 1.years.to_i..@time.to_i)
                                                  .count / 52.0

    @graph_notes = DrupalNode.weekly_tallies('note', 52, @time).to_a.sort.to_json
    @graph_wikis = DrupalNode.weekly_tallies('page', 52, @time).to_a.sort.to_json
    @graph_comments = DrupalComment.comment_weekly_tallies(52, @time).to_a.sort.to_json

    users = []
    nids = []
    DrupalNode.find(:all, :conditions => {:type => 'note', :status => 1}).each do |note|
      unless note.uid == 674 || note.uid == 671
        users << note.uid
        nids << note.nid
      end
    end

    @all_notes = nids.uniq.length
    @all_contributors = users.uniq.length
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
      @node = DrupalNode.find params[:id]
      @node = @node || DrupalNode.where(path: "/report/#{params[:id]}").first
      redirect_old_urls
    else
      @node = DrupalNode.find params[:id]
    end

    return if check_and_redirect_node(@node)

    alert_and_redirect_moderated

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
        if current_user.first_time_poster
          AdminMailer.notify_node_moderators(@node)
          flash[:first_time_post] = true
          flash[:notice] = "Success! Thank you for contributing open research, and thanks for your patience while your post is approved by <a href='/wiki/moderation'>community moderators</a> and we'll email you when it is published. In the meantime, if you have more to contribute, feel free to do so."
        else
          flash[:notice] = "Research note published. Get the word out on <a href='/lists'>the discussion lists</a>!"
        end
        # Notice: Temporary redirect.Remove this condition after questions show page is complete.
        #         Just keep @node.path(:question)
        if params[:redirect] && params[:redirect] == 'question'
          redirect_to @node.path(:question)
        else
          if request.xhr?
            render text: @node.path
          else
            redirect_to @node.path
          end
        end
      else
        render :template => "editor/post"
      end
    else
      flash.keep[:error] = "You have been banned. Please contact <a href='mailto:moderators@publiclab.org'>moderators@publiclab.org</a> if you believe this is in error."
      redirect_to "/logout"
    end
  end

  def edit
    @node = DrupalNode.find(params[:id],:conditions => {:type => "note"})
    if current_user.uid == @node.uid || current_user.role == "admin"
      if params[:rich]
        if @node.main_image
          @main_image = @node.main_image.path(:default)
        elsif params[:main_image] && Image.find_by_id(params[:main_image])
          @main_image = Image.find_by_id(params[:main_image]).path
        elsif @image
          @main_image = @image.path(:default)
        end
        render :template => "editor/rich"
      else
        render :template => "editor/post"
      end
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
            @node.main_image_id = img.id
            img.save
          end
        end
        @node.save!
        flash[:notice] = "Edits saved."
        # Notice: Temporary redirect.Remove this condition after questions show page is complete.
        #         Just keep @node.path(:question)
        format = false
        format = :question if params[:redirect] && params[:redirect] == 'question'
        if request.xhr?
          render text: @node.path(format) + "?_=" + Time.now.to_i.to_s
        else
          redirect_to @node.path(format) + "?_=" + Time.now.to_i.to_s
        end
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
            redirect_to "/dashboard" + "?_=" + Time.now.to_i.to_s
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
        response.headers["Access-Control-Allow-Origin"] = "*"
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
