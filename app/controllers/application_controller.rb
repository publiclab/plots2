class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  helper_method :current_user_session, :current_user, :prompt_login, :sidebar

  private

    # eventually videos could be a power tag
    def set_sidebar(type = :generic, data = :all, args = {})
      args[:note_count] ||= 8
      if type == :tags # accepts data of array of tag names as strings
        @notes = @notes || DrupalTag.find_nodes_by_type(data,'note',args[:note_count])
        @wikis = DrupalTag.find_pages(data,10)
        @videos = DrupalTag.find_nodes_by_type_with_all_tags(['video']+data,'note',8) if args[:videos] && data.length > 1
        @maps = DrupalTag.find_nodes_by_type(data,'map',20)
      else # type is generic
        @notes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'note', :status => 1}, :limit => 10, :page => params[:page])
        @wikis = DrupalNode.find(:all, :order => "changed DESC", :conditions => {:status => 1, :type => 'page'}, :limit => 10)
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
        redirect_to users_url # TODO: change this to the main page
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

end
