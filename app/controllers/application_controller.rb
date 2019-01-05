include ActionView::Helpers::DateHelper # required for time_ago_in_words()
class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  helper_method :current_user_session, :current_user, :prompt_login, :sidebar

  before_action :set_locale

  private

  # eventually videos could be a power tag
  def set_sidebar(type = :generic, data = :all, args = {})
    args[:note_count] ||= 8
    if type == :tags # accepts data of array of tag names as strings
      if params[:controller] == 'questions'
        @notes ||= Tag.find_nodes_by_type(data, 'note', args[:note_count])
      else
        @notes ||= Tag.find_research_notes(data, args[:note_count])
      end

      @notes = @notes.where('node.nid != (?)', @node.nid) if @node
      @wikis = Tag.find_pages(data, 10)
      @videos = Tag.find_nodes_by_type_with_all_tags(['video'] + data, 'note', 8) if args[:videos] && data.length > 1
      @maps = Tag.find_nodes_by_type(data, 'map', 20)
    else # type is generic
      # remove "classroom" postings; also switch to an EXCEPT operator in sql, see https://github.com/publiclab/plots2/issues/375
      hidden_nids = Node.joins(:node_tag)
        .joins('LEFT OUTER JOIN term_data ON term_data.tid = community_tags.tid')
        .select('node.*, term_data.*, community_tags.*')
        .where(type: 'note', status: 1)
        .where('term_data.name = (?)', 'hidden:response')
        .collect(&:nid)
      @notes = if params[:controller] == 'questions'
                 Node.questions
                   .joins(:revision)
               else
                 Node.research_notes.joins(:revision).order('node.nid DESC').paginate(page: params[:page])
      end

      @notes = @notes.where('node.nid != (?)', @node.nid) if @node
      @notes = @notes.where('node_revisions.status = 1 AND node.nid NOT IN (?)', hidden_nids) unless hidden_nids.empty?

      if current_user && (current_user.role == 'moderator' || current_user.role == 'admin')
        @notes = @notes.where('(node.status = 1 OR node.status = 4)')
      elsif current_user
        @notes = @notes.where('(node.status = 1 OR (node.status = 4 AND node.uid = ?))', current_user.uid)
      else
        @notes = @notes.where('node.status = 1')
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
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
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
      flash[:warning] = "The user '#{@current_user.username}' has been placed in moderation; please see <a href='https://#{request.host}/wiki/moderators'>our moderation policy</a> and contact <a href='mailto:moderators@#{request.host}'>moderators@#{request.host}</a> if you believe this is in error."
      # Same effect as if the user clicked logout:
      current_user_session.destroy
      # Ensures no code will use old @current_user info. Treat the user
      # as anonymous (until the login process sets @current_user again):
      @current_user = nil
    end
    @current_user
  end

  def require_user
    unless current_user
      store_location
      flash[:warning] ||= I18n.t('application_controller.must_be_logged_in_to_access')
      redirect_to login_url
      false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = I18n.t('application_controller.must_be_logged_out_to_access')
      redirect_to home_url + '?return_to=' + URI.encode(request.env['PATH_INFO'])
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

  def check_and_redirect_node(node)
    if !node.nil? && node.type[/^redirect\|/]
      node = Node.find(node.type[/\|\d+/][1..-1])
      redirect_to node.path, status: 301
      return true
    end
    false
  end

  def alert_and_redirect_moderated
    if @node.author.status == 0 && !(current_user && (current_user.role == 'admin' || current_user.role == 'moderator'))
      flash[:error] = I18n.t('application_controller.author_has_been_banned')
      redirect_to '/'
    elsif @node.status == 4 && (current_user && (current_user.role == 'admin' || current_user.role == 'moderator'))
      flash.now[:warning] = "First-time poster <a href='/profile/#{@node.author.name}'>#{@node.author.name}</a> submitted this #{time_ago_in_words(@node.created_at)} ago and it has not yet been approved by a moderator. <a class='btn btn-default btn-sm' href='/moderate/publish/#{@node.id}'>Approve</a> <a class='btn btn-default btn-sm' href='/moderate/spam/#{@node.id}'>Spam</a>"
    elsif @node.status == 4 && (current_user && current_user.id == @node.author.id) && !flash[:first_time_post]
      flash.now[:warning] = "Thank you for contributing open research, and thanks for your patience while your post is approved by <a href='/wiki/moderation'>community moderators</a> and we'll email you when it is published. In the meantime, if you have more to contribute, feel free to do so."
    elsif @node.status == 3 && (current_user && (current_user.is_coauthor(@node) || current_user.can_moderate?)) && !flash[:first_time_post]
      flash.now[:warning] = "This is a draft note. Once you're ready, click <a class='btn btn-success btn-xs' href='/notes/publish_draft/#{@node.id}'>Publish Draft</a> to make it public. You can share it with collaborators using this private link <a href='#{@node.draft_url}'>#{@node.draft_url}</a>"
    elsif @node.status != 1 && @node.status != 3 && !(current_user && (current_user.role == 'admin' || current_user.role == 'moderator'))
      # if it's spam or a draft
      # no notification; don't let people easily fish for existing draft titles; we should try to 404 it
      redirect_to '/'
    elsif @node.author.status == 5
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
    @node = if @comment.aid == 0
              # finding node for node comments
              @comment.node
            else
              # finding node for answer comments
              @comment.answer.node
    end

    @path = if params[:type] && params[:type] == 'question'
              # questions path
              @node.path(:question)
            else
              # notes path
              @node.path
    end
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
end
