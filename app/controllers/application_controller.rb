class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  helper_method :current_user_session, :current_user, :prompt_login, :sidebar
  
  before_filter :set_locale

  private

    # eventually videos could be a power tag
    def set_sidebar(type = :generic, data = :all, args = {})
      args[:note_count] ||= 8
      if type == :tags # accepts data of array of tag names as strings
        if params[:controller] == 'questions'
          @notes = @notes || DrupalTag.find_nodes_by_type(data, 'note', args[:note_count])
        else
          @notes = @notes || DrupalTag.find_research_notes(data, args[:note_count])
        end
        
        @notes = @notes.where('node.nid != (?)', @node.nid) if @node
        @wikis = DrupalTag.find_pages(data,10)
        @videos = DrupalTag.find_nodes_by_type_with_all_tags(['video']+data,'note',8) if args[:videos] && data.length > 1
        @maps = DrupalTag.find_nodes_by_type(data,'map',20)
      else # type is generic
        # remove "classroom" postings; also switch to an EXCEPT operator in sql, see https://github.com/publiclab/plots2/issues/375
        hidden_nids = DrupalNode.joins(:drupal_node_community_tag)
                                .joins("LEFT OUTER JOIN term_data ON term_data.tid = community_tags.tid")
                                .select('node.*, term_data.*, community_tags.*')
                                .where(type: 'note', status: 1)
                                .where('term_data.name = (?)', 'hidden:response')
                                .collect(&:nid)
        @notes = DrupalNode.research_notes
                           .joins(:drupal_node_revision)
                           .order('node.nid DESC')
                           .paginate(page: params[:page])
        @notes = @notes.where('node.nid != (?)', @node.nid) if @node
        @notes = @notes.where('node_revisions.status = 1 AND node.nid NOT IN (?)', hidden_nids) if hidden_nids.length > 0

        if current_user && (current_user.role == "moderator" || current_user.role == "admin")
          @notes = @notes.where('(node.status = 1 OR node.status = 4)')
        elsif current_user
          @notes = @notes.where('(node.status = 1 OR (node.status = 4 AND node.uid = ?))', current_user.uid)
        else
          @notes = @notes.where('node.status = 1')
        end

        @wikis = DrupalNode.order("changed DESC")
                           .joins(:drupal_node_revision)
                           .where('node_revisions.status = 1 AND node.status = 1 AND type = "page"')
                           .limit(10)
                           .group('node_revisions.nid')
                           .order('node_revisions.timestamp DESC')
      end
    end
    
    # non-Authlogic... homebrew
    def prompt_login(message = "You must be logged in to do that.")
      flash[:warning] = message
      redirect_to "/login"
    end

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      if not defined?(@current_user)
        @current_user = current_user_session && current_user_session.record
      end
      if @current_user && @current_user.drupal_user.status == 0
        # Tell the user they are banned. Fails b/c redirect to require below.
        #flash[:notice] = "The user '"+@current_user.username+"' has been banned; please contact <a href='mailto:web@publiclab.org'>web@publiclab.org</a> if you believe this is in error."
        # If user is banned, kiss their session goodbye.
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
        flash[:notice] = "You must be logged in to access this page"
        redirect_to login_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to home_url+'?return_to=' + URI.encode(request.env['PATH_INFO'])
        return false
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
        node = DrupalNode.find(node.type[/\|\d+/][1..-1])
        redirect_to node.path, status: 301
        return true
      end
      false
    end

  def alert_and_redirect_moderated
    if @node.author.status == 0 && !(current_user && (current_user.role == "admin" || current_user.role == "moderator"))
      flash[:error] = "The author of that note has been banned."
      redirect_to "/"
    elsif @node.status == 4 && (current_user && (current_user.role == "admin" || current_user.role == "moderator"))
      flash[:warning] = "First-time poster <a href='#{@node.author.name}'>#{@node.author.name}</a> submitted this #{time_ago_in_words(@node.created_at)} ago and it has not yet been approved by a moderator. <a class='btn btn-default btn-sm' href='/moderate/publish/#{@node.id}'>Approve</a> <a class='btn btn-default btn-sm' href='/moderate/spam/#{@node.id}'>Spam</a>"
    elsif @node.status == 4 && (current_user && current_user.id == @node.author.id) && !flash[:first_time_post]
      flash[:warning] = "Thank you for contributing open research, and thanks for your patience while your post is approved by <a href='/wiki/moderation'>community moderators</a> and we'll email you when it is published. In the meantime, if you have more to contribute, feel free to do so."
    elsif @node.status != 1 && !(current_user && (current_user.role == "admin" || current_user.role == "moderator"))
      # if it's spam or a draft
      # no notification; don't let people easily fish for existing draft titles; we should try to 404 it
      redirect_to "/"
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
      if @comment.aid == 0
        # finding node for node comments
        @node = @comment.node
      else
        # finding node for answer comments
        @node = @comment.answer.node
      end

      if params[:type] && params[:type] == 'question'
        # questions path
        @path = @node.path(:question)
      else
        # notes path
        @path = @node.path
      end
    end

    def redirect_old_urls
      # If an old id or a numeric id was used to find the record, then
      # the request path will not match the notes path, and we should do
      # a 301 redirect that uses the current friendly id.
      if request.path != @node.path
        return redirect_to @node.path, :status => :moved_permanently
      end
    end

    def sort_question_by_tags
      if session[:tags] && !session[:tags].empty?
        @session_tags = session[:tags]
        qids = @questions.collect(&:nid)
        @questions = DrupalNode.where(status: 1, type: 'note')
                      .joins(:drupal_tag)
                      .where('term_data.name IN (?)', @session_tags.values)
                      .where('node.nid IN (?)', qids)
                      .group('node.nid')
      end
    end

end
