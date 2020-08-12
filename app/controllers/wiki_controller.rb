require 'rss'

class WikiController < ApplicationController
  before_action :require_user, only: %i(new create edit update delete replace)

  def subdomain
    url = "//#{request.host}/wiki/"
    case request.subdomain
    when 'new-york-city',
         'gulf-coast',
         'boston',
         'espana' then
      redirect_to url + request.subdomain
    when 'nyc'
      redirect_to url + 'new-york-city'
    else
      redirect_to url
    end
  end

  def show
    @node = if params[:lang]
              Node.find_wiki(params[:lang] + '/' + params[:id])
            else
              Node.find_wiki(params[:id])
    end

    if @node&.has_power_tag('redirect') && Node.where(nid: @node.power_tag('redirect')).exists?
      if current_user.nil? || !current_user.can_moderate?
        redirect_to Node.find(@node.power_tag('redirect')).path
        return
      elsif current_user.can_moderate?
        flash.now[:warning] = "Only moderators and admins see this page, as it is redirected to <a href='#{Node.find(@node.power_tag('redirect')).path}'>#{Node.find(@node.power_tag('redirect')).title}</a>.
        To remove the redirect, delete the tag beginning with 'redirect:'"
      end

    elsif @node&.has_power_tag('redirect') && Node.where(slug: @node.power_tag('redirect')).exists?
      if current_user.nil? || !current_user.can_moderate?
        redirect_to Node.find_by(slug: @node.power_tag('redirect')).path
        return
      elsif current_user.can_moderate?
        flash.now[:warning] = "Only moderators and admins see this page, as it is redirected to <a href='#{Node.find_by(slug: @node.power_tag('redirect')).path}'>#{Node.find_by(slug: @node.power_tag('redirect')).title}</a>.
        To remove the redirect, delete the tag beginning with 'redirect:'"
      end
      if @node&.has_power_tag('abtest') && !Node.where(nid: @node.power_tag('abtest')).empty?
        if current_user.nil? || !current_user.can_moderate?
          if Random.rand(2) == 0
            redirect_to Node.find(@node.power_tag('abtest')).path
            return
          end
        elsif current_user.can_moderate?
          flash.now[:warning] = "Only moderators and admins see this page, as it is redirected to #{Node.find(@node.power_tag('abtest')).title} roughly around 50% of the time.
        To remove this behavior, delete the tag beginning with 'abtest:'"
        end
      end
    end

    return if redirect_to_node_path?(@node)

    if !@node.nil? # it's a place page!
      @tags = @node.tags
      @tags += [Tag.find_by(name: params[:id])] if Tag.find_by(name: params[:id])
    else # it's a new wiki page!
      @title = I18n.t('wiki_controller.new_wiki_page')
      if current_user
        new
      else
        flash[:warning] = I18n.t('wiki_controller.pages_does_not_exist')
        redirect_to '/login'
      end
    end

    unless @title # the page exists
      if @node.status == 0
        flash[:warning] = I18n.t('wiki_controller.page_moderated_as_spam')
        redirect_to '/wiki'
      end
      @tagnames = @tags.collect(&:name)
      set_sidebar :tags, @tagnames, videos: true
      @wikis = Tag.find_pages(@node.slug_from_path, 30) if @node.has_tag('chapter') || @node.has_tag('tabbed:wikis')

      impressionist(@node, 'show', unique: [:ip_address])
      @revision = @node.latest # needed for template, so it can be used for past revisions too in the "revision" action
      @title = @revision.title
    end
    @unpaginated = true
  end

  # display a revision, raw
  def raw
    response.headers['Content-Type'] = 'text/plain; charset=utf-8'
    render plain: Revision.find(params[:id]).body
  end

  def edit
    @node = if params[:lang]
              Node.find_wiki(params[:lang] + '/' + params[:id])
            else
              Node.find_wiki(params[:id])
    end

    if @node.has_tag('locked') && !current_user.can_moderate?
      flash[:warning] = "This page is <a href='/wiki/power-tags#Locking'>locked</a>, and only <a href='/wiki/moderators'>moderators</a> can edit it."
      redirect_to @node.path
    elsif current_user &.first_time_poster
      flash[:notice] = "Please post a question or other content before editing the wiki. Click <a href='https://publiclab.org/notes/tester/04-23-2016/new-moderation-system-for-first-time-posters'>here</a> to learn why."
      redirect_to Node.find_wiki(params[:id]).path
      return
    end
    if ((Time.now.to_i - @node.latest.timestamp) < 5.minutes.to_i) && @node.latest.author.uid != current_user.uid
      flash.now[:warning] = I18n.t('wiki_controller.someone_clicked_edit_5_minutes_ago')
    end
    # we could do this...
    # @node.locked = true
    # @node.save
    @title = I18n.t('wiki_controller.editing', title: @node.title).html_safe

    @tags = @node.tags
  end

  def new
    if current_user &.first_time_poster
      flash[:notice] = "Please post a question or other content before editing the wiki. Click <a href='https://publiclab.org/notes/tester/04-23-2016/new-moderation-system-for-first-time-posters'>here</a> to learn why."
      redirect_to '/'
      return
    end
    @node = Node.new
    if params[:n] && !params[:body] # use another node body as a template
      node = Node.find(params[:n])
      params[:body] = node.latest.body if node&.latest
    end
    @tags = []
    if params[:id]
      flash.now[:notice] = I18n.t('wiki_controller.page_does_not_exist_create')
      title = params[:id].tr('-', ' ')
      @related = Node.limit(10)
        .order('node.nid DESC')
        .where('type = "page" AND node.status = 1 AND (node.title LIKE ? OR node_revisions.body LIKE ?)', '%' + title + '%', '%' + title + '%')
        .includes(:revision)
        .references(:node_revisions)
      tag = Tag.find_by(name: params[:id]) # add page name as a tag, too
      @tags << tag if tag
      @related += Tag.find_nodes_by_type(@tags.collect(&:name), 'page', 10)
    end
    if params[:rich]
      render template: 'editor/wikiRich'
    else
      respond_to do |format|
        format.html { render 'wiki/edit' }
        format.all { head :ok }
      end
    end
  end

  def create
    if current_user.status == 1
      # we no longer allow custom urls, just titles which are parameterized automatically into urls
      # slug = params[:title].parameterize
      # slug = params[:id].parameterize if params[:id] != "" && !params[:id].nil?
      # slug = params[:url].parameterize if params[:url] != "" && !params[:url].nil?
      saved, @node, @revision = Node.new_wiki(uid:   current_user.uid,
                                              title: params[:title],
                                              body:  params[:body])
      if saved
        flash[:notice] = I18n.t('wiki_controller.wiki_page_created')
        params[:tags]&.tr(' ', ',')&.split(',')&.each do |tagname|
          @node.add_tag(tagname.strip, current_user)
        end
        if params[:main_image] && params[:main_image] != ''
          img = Image.find params[:main_image]
          img.nid = @node.id
          img.save
        end
        redirect_to @node.path
      else
        if params[:main_image] && Image.find_by(id: params[:main_image])
          @main_image = Image.find_by(id: params[:main_image]).path
        end
        if params[:n] && !params[:body] # use another node body as a template
          node = Node.find(params[:n])
          params[:body] = node.body if node
        end
        flash[:error] = "Please enter both body and title"
        render template: 'editor/wikiRich'
      end
    else
      flash.keep[:error] = I18n.t('wiki_controller.you_have_been_banned').html_safe
      redirect_to '/logout'
    end
  end

  def update
    @node = Node.find(params[:id])
    @revision = @node.new_revision(uid:   current_user.uid,
                                   title: params[:title],
                                   body:  params[:body])

    if @node.has_tag('locked') && !current_user.can_moderate?
      flash[:warning] = "This page is <a href='/wiki/power-tags#Locking'>locked</a>, and only <a href='/wiki/moderators'>moderators</a> can update it."
      redirect_to @node.path

    elsif @revision.valid?
      @revision.save
      update_node_attributes

      flash[:notice] = I18n.t('wiki_controller.edits_saved')
      redirect_to @node.path
    else
      flash[:error] = I18n.t('wiki_controller.edit_could_not_be_saved')
      render action: :edit
    end
  end

  def delete
    @node = Node.find(params[:id])
    if current_user&.admin?
      @node.destroy
      flash[:notice] = I18n.t('wiki_controller.wiki_page_deleted')
      redirect_to '/dashboard'
    else
      flash[:error] = I18n.t('wiki_controller.only_admins_delete_pages')
      redirect_to @node.path
    end
  end

  def revert
    revision = Revision.find params[:id]
    node = revision.parent
    if current_user&.can_moderate?
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
  # also just redirect anything else matching /____ to /wiki/____
  def root
    @node = Node.find_by(path: "/" + params[:id])
    return if redirect_to_node_path?(@node)

    if @node
      @revision = @node.latest
      @title = @revision.title
      @tags = @node.tags
      @tagnames = @tags.collect(&:name)
      render template: 'wiki/show'
    elsif !Node.find_by(slug: params[:id]).nil?
      redirect_to URI.parse('/wiki/' + params[:id]).path
    else
      redirect_to URI.parse('/tag/' + params[:id]).path
    end
  end

  def revisions
    @node = Node.find_wiki(params[:id])
    if @node
      @revisions = @node.revisions
      @revisions = @revisions.where(status: 1).page(params[:page]).per_page(20) unless current_user&.can_moderate?
      @title = I18n.t('wiki_controller.revisions_for', title: @node.title).html_safe
      @tags = @node.tags
      @paginated = true unless current_user&.can_moderate?
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
    set_sidebar :tags, @tagnames, videos: true
    @revision = Revision.find_by_nid_and_vid(@node.id, params[:vid])
    if @revision.nil?
      flash[:error] = I18n.t('wiki_controller.revision_not_found')
      redirect_to action: 'revisions'
    elsif @revision.status == 1 || current_user&.can_moderate?
      @title = I18n.t('wiki_controller.revisions_for', title: @revision.title).html_safe
      render template: 'wiki/show'
    else
      flash[:error] = I18n.t('wiki_controller.revision_has_been_moderated').html_safe
      redirect_to @node.path
    end
  end

  def diff
    @a = Revision.find_by(vid: params[:a])
    @b = Revision.find_by(vid: params[:b])
    if @a.body == @b.body
      render plain: I18n.t('wiki_controller.lead_image_or_title_change').html_safe
    else
      render partial: 'wiki/diff'
    end
  end

  def index
    @title = I18n.t('wiki_controller.wiki')
    sort_param = params[:sort]
    order_string = 'node_revisions.timestamp DESC'

    if sort_param == 'title'
      order_string = 'node_revisions.title ASC'
    elsif sort_param == 'last_edited'
      order_string = 'node_revisions.timestamp DESC'
    elsif sort_param == 'edits'
      order_string = 'drupal_node_revisions_count DESC'
    elsif sort_param == 'page_views'
      order_string = 'views DESC'
    elsif sort_param == 'likes'
      order_string = 'cached_likes DESC'
    end

    @wikis = Node.includes(:revision)
      .references(:node_revisions)
      .group('node_revisions.nid, node_revisions.vid')
      .order(order_string)
      .where("node_revisions.status = 1 AND node.status = 1 AND (type = 'page' OR type = 'tool' OR type = 'place')")
      .page(params[:page])

    @paginated = true
  end

  def stale
    @title = I18n.t('wiki_controller.wiki')

    @wikis = Node.includes(:revision)
      .references(:node_revisions)
      .group('node_revisions.nid, node_revisions.vid')
      .order('node_revisions.timestamp ASC')
      .where("node_revisions.status = 1 AND node.status = 1 AND (type = 'page' OR type = 'tool' OR type = 'place')")
      .page(params[:page])

    @paginated = true
    render template: 'wiki/index'
  end

  def popular
    @title = I18n.t('wiki_controller.popular_wiki_pages')
    @wikis = Node.limit(40)
      .joins(:revision)
      .group('node_revisions.nid, node_revisions.vid')
      .order('node_revisions.timestamp DESC')
      .where("node.status = 1 AND node_revisions.status = 1 AND node.nid != 259 AND (type = 'page' OR type = 'tool' OR type = 'place')")
      .sort_by(&:views).reverse
    render template: 'wiki/index'
  end

  def liked
    @title = I18n.t('wiki_controller.well_liked_wiki_pages')
    @wikis = Node.limit(40)
      .order('node.cached_likes DESC')
      .where("status = 1 AND nid != 259 AND (type = 'page' OR type = 'tool' OR type = 'place') AND cached_likes >= 0")

    render template: 'wiki/index'
  end

  # replace subsection of wiki body
  def replace
    @node = Node.find(params[:id])
    if params[:before] && params[:after]
      # during round trip, strings are getting "\r\n" newlines converted to "\n",
      # so we're ensuring they remain "\r\n"; this may vary based on platform, unfortunately
      before = params[:before] # params[:before].gsub("\n", "\r\n") # actually we're stopping this bc it didn't work...
      after  = params[:after] # .gsub( "\n", "\r\n")
      if output = @node.replace(before, after, current_user)
        flash[:notice] = 'New revision created with your additions.' unless request.xhr?
      else
        flash[:error] = 'There was a problem replacing that text.' unless request.xhr?
      end
    else
      flash[:error] = "You must specify 'before' and 'after' terms to replace content in a wiki page."
    end
    if request.xhr?
      if output.blank?
        render json: output, status: 500
      else
        render json: output
      end
    else
      redirect_to @node.path
    end
  end

  def techniques
    redirect_to '/methods', status: 302
  end

  def methods
    @nodes = Node.where(status: 1, type: %w(page))
      .where('term_data.name = ?', 'method')
      .includes(:revision, :tag)
      .references(:node_revision)
      .order('node_revisions.timestamp DESC')
    # deprecating the following in favor of javascript implementation in /app/assets/javascripts/methods.js
    if params[:topic]
      nids = @nodes.collect(&:nid) || []
      @notes = Node.where(status: 1, type: %w(page))
        .where('node.nid IN (?)', nids)
        .where('(type = "note" OR type = "page" OR type = "map") AND node.status = 1 AND (node.title LIKE ? OR node_revisions.title LIKE ? OR node_revisions.body LIKE ? OR term_data.name = ?)',
          '%' + params[:topic] + '%',
          '%' + params[:topic] + '%',
          '%' + params[:topic] + '%',
          params[:topic])
        .includes(:revision, :tag)
        .references(:node_revision, :term_data)
        .order('node_revisions.timestamp DESC')
    end
    if params[:topic]
      nids = @nodes.collect(&:nid) || []
      @nodes = Node.where(status: 1, type: %w(page))
        .where('node.nid IN (?)', nids)
        .where('(type = "note" OR type = "page" OR type = "map") AND node.status = 1 AND (node.title LIKE ? OR node_revisions.title LIKE ? OR node_revisions.body LIKE ? OR term_data.name = ?)',
          '%' + params[:topic] + '%',
          '%' + params[:topic] + '%',
          '%' + params[:topic] + '%',
          params[:topic])
        .includes(:revision, :tag)
        .references(:node_revision, :term_data)
        .order('node_revisions.timestamp DESC')
    end

    @unpaginated = true
    @topics = [
      'agriculture',
      'drinking-water',
      'fracking',
      'indoor-air',
      'chemicals',
      'industry',
      'land-use',
      'land-change',
      'mining',
      'oil-and-gas',
      'transportation',
      'urban-planning',
      'sensors',
      'community-organizing'
    ]
    render template: 'wiki/methods'
  end

  def comments
    show
    render :show
  end

  def update_node_attributes
    ActiveRecord::Base.transaction do
      @node.vid = @revision.vid
      @node.title = @revision.title

      if main_image = @node.drupal_main_image && params[:main_image].blank?
        main_image.vid = @revision.vid
        main_image.save
      end

      if params[:main_image].to_i == 0
        @node.main_image_id = nil
      elsif params[:main_image].present? && img = Image.find(params[:main_image])
        img.nid = @node.id
        @node.main_image_id = img.id
        img.save
      end

      @node.save
    end
  end

  def author
    @user = User.find_by(name: params[:id])
    @title = @user.name
    @wikis = Node.paginate(page: params[:page], per_page: 24)
      .order('nid DESC')
      .where("uid = ? AND type = 'page' OR type = 'place' OR type = 'tool' AND status = 1", @user.uid)
    render template: 'wiki/index'
  end
end
