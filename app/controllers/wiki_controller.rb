require 'rss'

class WikiController < ApplicationController

  before_filter :require_user, :only => [:new, :create, :edit, :update, :delete, :replace]

  def subdomain
    url = "//#{request.host}/wiki/"
    case request.subdomain
    when "new-york-city",
         "gulf-coast",
         "boston",
         "espana" then
      redirect_to url+request.subdomain
    when "nyc"
      redirect_to url+"new-york-city"
    else
      redirect_to url
    end
  end

  def show
    if params[:lang]
      @node = Node.find_wiki(params[:lang]+"/"+params[:id])
    else
      @node = Node.find_wiki(params[:id])
    end

    if @node && @node.has_power_tag('redirect')
      if current_user == nil || (current_user.role != 'admin' && current_user.role != 'moderator')
        redirect_to Node.find(@node.power_tag('redirect')).path
        return
      elsif (current_user.role == 'admin' || current_user.role == 'moderator')
        flash.now[:warning] = "Only moderators and admins see this page, as it is redirected to #{Node.find(@node.power_tag('redirect')).title}.
        To remove the redirect, delete the tag beginning with 'redirect:'"
      end
    end

    # if request.path != @node.path && request.path != '/wiki/' + @node.nid.to_s
    #   return redirect_to @node.path, :status => :moved_permanently
    # end

    return if check_and_redirect_node(@node)
    if !@node.nil? # it's a place page!
      @tags = @node.tags
      @tags += [Tag.find_by_name(params[:id])] if Tag.find_by_name(params[:id])
    else # it's a new wiki page!
      @title = I18n.t('wiki_controller.new_wiki_page')
      if current_user
        new
      else
        flash[:warning] = I18n.t('wiki_controller.pages_does_not_exist')
        redirect_to "/login"
      end
    end

    unless @title # the page exists
      if @node.status == 0
        flash[:warning] = I18n.t('wiki_controller.page_moderated_as_spam')
        redirect_to "/wiki"
      end
      @tagnames = @tags.collect(&:name)
      set_sidebar :tags, @tagnames, {:videos => true}
      @wikis = Tag.find_pages(@node.slug_from_path,30) if @node.has_tag('chapter') || @node.has_tag('tabbed:wikis')

      impressionist(@node, 'show', :unique => [:ip_address])
      @revision = @node.latest # needed for template, so it can be used for past revisions too in the "revision" action
      @title = @revision.title
    end
    @unpaginated = true
  end

  # display a revision, raw
  def raw
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    render :text => DrupalNodeRevision.find(params[:id]).body
  end

  def edit
    if params[:lang]
      @node = Node.find_wiki(params[:lang]+"/"+params[:id])
    else
      @node = Node.find_wiki(params[:id])
    end
    if @node.has_tag('locked') && (current_user.role != "admin" && current_user.role != "moderator")
      flash[:warning] = "This page is <a href='/wiki/power-tags#Locking'>locked</a>, and only <a href='/wiki/moderators'>moderators</a> can edit it."
      redirect_to @node.path
    end
    if ((Time.now.to_i - @node.latest.timestamp) < 5.minutes.to_i) && @node.latest.author.uid != current_user.uid
      flash.now[:warning] = I18n.t('wiki_controller.someone_clicked_edit_5_minutes_ago')
    end
    # we could do this...
    #@node.locked = true
    #@node.save
    @title = I18n.t('wiki_controller.editing', :title => @node.title).html_safe

    @tags = @node.tags
  end

  def new
    @node = Node.new
    if params[:n] && !params[:body] # use another node body as a template
      node = Node.find(params[:n])
      params[:body] = node.latest.body if node && node.latest
    end
    @tags = []
    if params[:id]
      flash.now[:notice] = I18n.t('wiki_controller.page_does_not_exist_create')
      title = params[:id].gsub('-',' ')
      @related = Node.limit(10)
                           .order("node.nid DESC")
                           .where('type = "page" AND node.status = 1 AND (node.title LIKE ? OR node_revisions.body LIKE ?)', "%" + title + "%","%" + title + "%")
                           .includes(:drupal_node_revision)
      tag = Tag.find_by_name(params[:id]) # add page name as a tag, too
      @tags << tag if tag
      @related += Tag.find_nodes_by_type(@tags.collect(&:name),'page',10)
    end
    render :template => 'wiki/edit'
  end

  def create
    if current_user.drupal_user.status == 1
      # we no longer allow custom urls, just titles which are parameterized automatically into urls
      #slug = params[:title].parameterize
      #slug = params[:id].parameterize if params[:id] != "" && !params[:id].nil?
      #slug = params[:url].parameterize if params[:url] != "" && !params[:url].nil?
      saved,@node,@revision = Node.new_wiki({
        uid:   current_user.uid,
        title: params[:title],
        body:  params[:body]
      })
      if saved
        flash[:notice] = I18n.t('wiki_controller.wiki_page_created')
        if params[:main_image] && params[:main_image] != ""
          img = Image.find params[:main_image]
          img.nid = @node.id
          img.save
        end
        redirect_to @node.path
      else
        render :action => :edit
      end
    else
      flash.keep[:error] = I18n.t('wiki_controller.you_have_been_banned').html_safe
      redirect_to "/logout"
    end
  end

  def update
    @node = Node.find(params[:id])
    @revision = @node.new_revision({
      uid:   current_user.uid,
      title: params[:title],
      body:  params[:body]
    })
    if @node.has_tag('locked') && (current_user.role != "admin" && current_user.role != "moderator")
      flash[:warning] = "This page is <a href='/wiki/power-tags#Locking'>locked</a>, and only <a href='/wiki/moderators'>moderators</a> can update it."
      redirect_to @node.path
    
    elsif @revision.valid?
      ActiveRecord::Base.transaction do
        @revision.save
        @node.vid = @revision.vid
        # update vid (version id) of main image
        if @node.drupal_main_image && params[:main_image].nil?
          i = @node.drupal_main_image
          i.vid = @revision.vid
          i.save
        end
        @node.title = @revision.title
        # save main image
        if params[:main_image] && params[:main_image] != ""
          begin
            img = Image.find params[:main_image]
            unless img.nil?
              img.nid = @node.id
              @node.main_image_id = img.id
              img.save
            end
          rescue
          end
        end
        @node.save
      end
      flash[:notice] = I18n.t('wiki_controller.edits_saved')
      redirect_to @node.path
    else
      flash[:error] = I18n.t('wiki_controller.edit_could_not_be_saved')
      render :action => :edit
      #redirect_to "/wiki/edit/"+@node.slug
    end
  end

  def delete
    @node = Node.find(params[:id])
    if current_user && current_user.role == "admin"
      @node.transaction do
        @node.destroy
      end
      flash[:notice] = I18n.t('wiki_controller.wiki_page_deleted')
      redirect_to "/dashboard"
    else
      flash[:error] = I18n.t('wiki_controller.only_admins_delete_pages')
      redirect_to @node.path
    end
  end

  def revert
    revision = DrupalNodeRevision.find params[:id]
    node = revision.parent
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      new_rev = revision.dup
      new_rev.timestamp = DateTime.now.to_i
      if new_rev.save!
        flash[:notice] = I18n.t('wiki_controller.wiki_page_reverted')
      else
        flash[:error] = I18n.t('wiki_controller.problem_reverting')
      end
    else
      flash[:error] = I18n.t('wiki_controller.moderators_admin_delete_pages')
    end
    redirect_to node.path
  end

  # wiki pages which have a root URL, like /about
  def root
    @node = Node.find_by_path(params[:id])
    return if check_and_redirect_node(@node)
    if @node
      @revision = @node.latest
      @title = @revision.title
      @tags = @node.tags
      @tagnames = @tags.collect(&:name)
      render :template => "wiki/show"
    else
      render :file => "public/404"
    end
  end

  def revisions
    @node = Node.find_wiki(params[:id])
    if @node
      @revisions = @node.revisions
      @revisions = @revisions.where(status: 1) unless current_user && (current_user.role == "moderator" || current_user.role == "admin")
      @title = I18n.t('wiki_controller.revisions_for', :title => @node.title).html_safe
      @tags = @node.tags
    else
      flash[:error] = I18n.t('wiki_controller.invalid_wiki_page')
    end
  end

  def revision
    @node = Node.find_wiki(params[:id])
    @tags = @node.tags
    @tagnames = @tags.collect(&:name)
    @unpaginated = true
    @is_revision = true
    set_sidebar :tags, @tagnames, {:videos => true}
    @revision = DrupalNodeRevision.find_by_nid_and_vid(@node.id, params[:vid])
    if @revision.nil?
      flash[:error] = I18n.t('wiki_controller.revision_not_found')
      redirect_to action: 'revisions'
    elsif @revision.status == 1 || current_user && (current_user.role == "moderator" || current_user.role == "admin")
      @title = I18n.t('wiki_controller.revisions_for', :title => @revision.title).html_safe
      render :template => "wiki/show"
    else
      flash[:error] = I18n.t('wiki_controller.revision_has_been_moderated').html_safe
      redirect_to @node.path
    end
  end

  def diff
    @a = DrupalNodeRevision.find_by_vid(params[:a])
    @b = DrupalNodeRevision.find_by_vid(params[:b])
    if @a.body == @b.body
      render text: I18n.t('wiki_controller.lead_image_or_title_change').html_safe
    else
      render partial: 'wiki/diff'
    end
  end

  def index
    @title = I18n.t('wiki_controller.wiki')

    if params[:order] == 'alphabetic'
      order_string = "node_revisions.title ASC"
    else
      order_string = "node_revisions.timestamp DESC"
    end

    @wikis = Node.includes(:drupal_node_revision)
                       .group('node_revisions.nid')
                       .order(order_string)
                       .where("node_revisions.status = 1 AND node.status = 1 AND (type = 'page' OR type = 'tool' OR type = 'place')")
                       .page(params[:page])

    @paginated = true
  end

  def popular
    @title = I18n.t('wiki_controller.popular_wiki_pages')
    @wikis = Node.limit(40)
                       .order("views DESC")
                       .joins(:drupal_node_revision)
                       .group('node_revisions.nid')
                       .order("node_revisions.timestamp DESC")
                       .where("node.status = 1 AND node_revisions.status = 1 AND node.nid != 259 AND (type = 'page' OR type = 'tool' OR type = 'place')")
    render :template => "wiki/index"
  end

  def liked
    @title = I18n.t('wiki_controller.well_liked_wiki_pages')
    @wikis = Node.limit(40)
                       .order("node.cached_likes DESC")
                       .where("status = 1 AND nid != 259 AND (type = 'page' OR type = 'tool' OR type = 'place') AND cached_likes > 0")
    render :template => "wiki/index"
  end

  # replace subsection of wiki body
  def replace
    @node = Node.find(params[:id])
    if params[:before] && params[:after]
      if output = @node.replace(params[:before], params[:after], current_user)
        flash[:notice] = "New revision created with your additions." unless request.xhr?
      else
        flash[:error] = "There was a problem replacing that text." unless request.xhr?
      end
    else
      flash[:error] = "You must specify 'before' and 'after' terms to replace content in a wiki page."
    end
    if request.xhr?
      render json: output
    else
      redirect_to @node.path
    end
  end

  def methods
    @nodes = Node.where(status: 1, type: ['page'])
                       .where('term_data.name = ?', 'tool')
                       .includes(:drupal_node_revision, :tag)
                       .order("node_revisions.timestamp DESC")
    # deprecating the following in favor of javascript implementation in /app/assets/javascripts/methods.js
    if params[:topic]
      nids = @nodes.collect(&:nid) || []
<<<<<<< HEAD
      @nodes = DrupalNode.where(status: 1, type: ['page'])
=======
      @notes = Node.where(status: 1, type: ['page'])
>>>>>>> DrupalNode to drupal_node
                         .where('node.nid IN (?)', nids)
                         .where('(type = "note" OR type = "page" OR type = "map") AND node.status = 1 AND (node.title LIKE ? OR node_revisions.title LIKE ? OR node_revisions.body LIKE ? OR term_data.name = ?)', 
                           "%"+params[:topic]+"%",
                           "%"+params[:topic]+"%",
                           "%"+params[:topic]+"%",
                           params[:topic])
                         .includes(:drupal_node_revision, :tag)
                         .order("node_revisions.timestamp DESC")
    end
    @unpaginated = true
    @topics = [
      "agriculture",
      "drinking-water",
      "fracking",
      "indoor-air",
      "chemicals",
      "industry",
      "land-use",
      "land-change",
      "mining",
      "oil-and-gas",
      "transportation",
      "urban-planning",
      "sensors",
      "community-organizing"
    ]
    render template: "wiki/methods"
  end

end
