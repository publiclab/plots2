include ActionView::Helpers::DateHelper # required for time_ago_in_words()
include Pagy::Backend
class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { is_dataurl_post }
  layout 'application'

  helper_method :current_user_session, :current_user, :prompt_login, :sidebar

  before_action :set_locale

  before_action :set_raven_context

  private

  # allow limited CSRF from external apps submitting params[:dataurl_main_image] data
  def is_dataurl_post
    params[:controller] == "editor" && params[:action] == "post" && !params[:datauri_main_image].nil?
  end

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  # eventually videos could be a power tag
  def set_sidebar(type = :generic, data = :all, args = {})
    args[:note_count] ||= 8
    if type == :tags # accepts data of array of tag names as strings
      @notes ||= if params[:controller] == 'questions'
                   Tag.find_nodes_by_type(data, 'note', args[:note_count])
                 else
                   Tag.find_research_notes(data, args[:note_count])
                 end

      @notes = @notes.where('node.nid != (?)', @node.nid) if @node
      @wikis = Tag.find_pages(data, 10)
      @videos = Tag.find_nodes_by_type_with_all_tags(%w(video) + data, 'note', 8) if args[:videos] && data.length > 1
      @maps = Tag.find_nodes_by_type(data, 'map', 20)
    else # type is generic
      # remove "classroom" postings; also switch to an EXCEPT operator in sql, see https://github.com/publiclab/plots2/issues/375
      hidden_nids = Node.where(type: :note, status: 1).select { |n| n.has_a_tag('hidden:response') }.collect(&:nid)
      @notes = if params[:controller] == 'questions'
                 Node.questions
                   .joins(:revision)
               else
                 Node.research_notes.joins(:revision).order('node.nid DESC').paginate(page: params[:page])
      end

      @notes = @notes.where('node.nid != (?)', @node.nid) if @node
      @notes = @notes.where('node_revisions.status = 1 AND node.nid NOT IN (?)', hidden_nids) unless hidden_nids.empty?

      @notes = if logged_in_as(['admin', 'moderator'])
                 @notes.where('(node.status = 1 OR node.status = 4)')
               elsif current_user
                 @notes.where('(node.status = 1 OR (node.status = 4 AND node.uid = ?))', current_user.uid)
               else
                 @notes.where('node.status = 1')
               end

      @wikis = Node.order('changed DESC')
        .joins(:revision)
        .where('node_revisions.status = 1 AND node.status = 1 AND type = "page"')
        .limit(10)
        .group('node_revisions.nid')
        .order('node_revisions.timestamp DESC')
    end
  end

  # non-Authlogic... homebrew
  def prompt_login(message = I18n.t('application_controller.must_be_logged_in'))
    flash[:warning] = message
    redirect_to '/login'
  end

  def current_user_session
    @current_user_session ||= UserSession.find
  end

  def current_user
    unless defined?(@current_user)
      @current_user = current_user_session&.record
    end
    # if banned or moderated:
    if @current_user.try(:status) == 0
      # Same effect as if the user clicked logout:
      current_user_session.destroy
      # Ensures no code will use old @current_user info. Treat the user
      # as anonymous (until the login process sets @current_user again):
      @current_user = nil
    elsif @current_user.try(:status) == 5
      # Tell the user they are banned. Fails b/c redirect to require below.
      flash[:warning] = "The user '#{@current_user.username}' has been placed in moderation; please see <a href='https://#{request.host}/wiki/moderators'>our moderation policy</a> and contact <a href='mailto:moderators@#{request.host}?body=Please make sure to include your username and the email address you used to sign up for the site.'>moderators@#{request.host}</a> if you believe this is in error."
      # Same effect as if the user clicked logout:
      current_user_session.destroy
      # Ensures no code will use old @current_user info. Treat the user
      # as anonymous (until the login process sets @current_user again):
      @current_user = nil

    end

    cookies.signed["user_token"] = nil
    if @current_user
      cookies.signed["user_token"] = @current_user.persistence_token
    end
    @current_user
  end

  def require_user
    unless current_user
      store_location
      flash[:warning] ||= I18n.t('application_controller.must_be_logged_in_to_access')
      redirect_to "/login?return_to=" + request.fullpath
      false
    end
    return current_user
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = I18n.t('application_controller.must_be_logged_out_to_access')

      url = URI.parse(home_url + '?return_to=' + CGI.escape(request.env['PATH_INFO'])).to_s

      redirect_to url
      false
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def redirect_to_node_path?(node)
    return false unless node.present? && node.type[/^redirect\|/] && node.status == 1

    node = Node.find(node.type[/\|\d+/][1..-1])
    redirect_to URI.parse(node.path).path, status: :moved_permanently

    true
  end

  def alert_and_redirect_moderated
    if @node.author.status == User::Status::BANNED && !(logged_in_as(['admin', 'moderator']))
      flash[:error] = I18n.t('application_controller.author_has_been_banned')
      redirect_to '/'
    elsif @node.status == 4 && (logged_in_as(['admin', 'moderator']))
      flash.now[:warning] = "First-time poster <a href='/profile/#{@node.author.name}'>#{@node.author.name}</a> submitted this #{time_ago_in_words(@node.created_at)} ago and it has not yet been approved by a moderator. <a class='btn btn-default btn-sm' href='/moderate/publish/#{@node.id}'>Approve</a> <a class='btn btn-default btn-sm' href='/moderate/spam/#{@node.id}'>Spam</a>"
    elsif @node.status == 4 && current_user&.id == @node.author.id && !flash[:first_time_post]
      flash.now[:warning] = "Thank you for contributing open research, and thanks for your patience while your post is approved by <a href='/wiki/moderation'>community moderators</a> and we'll email you when it is published. In the meantime, if you have more to contribute, feel free to do so."
    elsif @node.status == 3 && (current_user&.is_coauthor?(@node) || current_user&.can_moderate?) && !flash[:first_time_post]
      flash.now[:warning] = "This is a draft note. Once you're ready, click <a class='btn btn-success btn-xs' href='/notes/publish_draft/#{@node.id}'>Publish Draft</a> to make it public. You can share it with collaborators using this private link <a href='#{@node.draft_url(request.base_url)}'>#{@node.draft_url(request.base_url)}</a>"
    elsif @node.status == 3 && (params[:token].nil? || (params[:token].present? && @node.slug.split('token:').last != params[:token]))
      page_not_found
    elsif @node.status != 1 && @node.status != 3 && !(logged_in_as(['admin', 'moderator']))
      # if it's spam or a draft
      # no notification; don't let people easily fish for existing draft titles; we should try to 404 it
      redirect_to '/'
    elsif @node.author.status == User::Status::MODERATED
      flash.now[:warning] = "The user '#{@node.author.username}' has been placed <a href='https://#{request.host}/wiki/moderators'>in moderation</a> and will not be able to respond to comments."
    end
  end

  # Check the locale set and adjust the locale accordingly
  def set_locale
    if cookies[:plots2_locale] && I18n.available_locales.include?(cookies[:plots2_locale].to_sym)
      lang = cookies[:plots2_locale].to_sym
    else
      lang = http_accept_language.compatible_language_from(I18n.available_locales) || I18n.default_locale
      cookies.permanent[:plots2_locale] = lang
    end
    I18n.locale = lang
  end

  def comments_node_and_path
    @node = @comment.aid == 0 ? @comment.node : @comment.answer.node

    @path = params[:type] && params[:type] == 'question' ? @node.path(:question) : @node.path
  end

  # used for url redirects for friendly_id
  # currently unused for issues discussed in https://github.com/publiclab/plots2/issues/691
  def redirect_old_urls
    # If an old id or a numeric id was used to find the record, then
    # the request path will not match the notes path, and we should do
    # a 301 redirect that uses the current friendly id.
    if request.path != @node.path
      redirect_to @node.path, status: :moved_permanently
    end
  end

  def signed_in?
    !current_user.nil?
  end

  def page_not_found
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end

  # TODO: make less redundant with https://github.com/publiclab/plots2/blob/main/app/helpers/application_helper.rb#L3
  def logged_in_as(roles)
    return false unless current_user

    has_valid_role = false
    roles.each do |role|
      has_valid_role = true if current_user.role == role
    end
    has_valid_role
  end
end
