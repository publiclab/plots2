class UserSessionsController < ApplicationController

  def new
    @title = I18n.t('user_sessions_controller.log_in')
  end

  def create
    params[:user_session][:username] = params[:openid] if params[:openid] # second runthrough must preserve username 
    username = params[:user_session][:username] if params[:user_session]
    @user = User.find_by_username(username)

    # try finding by email, if that exists
    if @user.nil? and User.where(email: username).length > 0
     @user = User.find_by_email(username) 
     params[:user_session][:username] = @user.username
    end 
    
    if params[:user_session].nil? || @user && @user.drupal_user.status == 1 || @user.nil?
    # an existing native user
      if params[:user_session].nil? || @user
        if @user && @user.crypted_password.nil? # the user has not created a pwd in the new site
          params[:user_session][:openid_identifier] = "https://old.publiclab.org/people/"+username+"/identity" if username
          params[:user_session].delete(:password)
          params[:user_session].delete(:username)
          params[:openid] = username # pack up username for second runthrough
        end
        @user_session = UserSession.new(params[:user_session])
          saved = @user_session.save do |result|
          if result
            # replace this with temporarily saving pwd in session,
            # and automatically saving it in the user record after login is completed
            if current_user.crypted_password.nil? # the user has not created a pwd in the new site
              flash[:warning] = I18n.t('user_sessions_controller.create_password_for_new_site')
              redirect_to "/profile/edit"
            else
              flash[:notice] =I18n.t('user_sessions_controller.logged_in')
              if session[:openid_return_to] # for openid login, redirects back to openid auth process
                return_to = session[:openid_return_to]
                session[:openid_return_to] = nil
                redirect_to return_to
              elsif session[:return_to]
                return_to = session[:return_to]
                session[:return_to] = nil
                redirect_to return_to
              elsif params[:return_to]
                redirect_to params[:return_to]
              else
                redirect_to "/dashboard"
              end
            end
          else
            render :action => 'new'
          end
        end
      else # not a native user
        if !DrupalUsers.find_by_name(username).nil?
          # this is a user from the old site who hasn't registered on the new site
          redirect_to :controller => :users, :action => :create, :user => {:openid_identifier => username}
        else # totally new user!
          flash[:warning] = I18n.t('user_sessions_controller.sign_up_to_join')
          redirect_to "/signup"
        end
      end
    elsif params[:user_session].nil? || @user && @user.drupal_user.status == 5 || @user.nil?
      flash[:error] = I18n.t('user_sessions_controller.user_has_been_moderated', :username => @user.username).html_safe
      redirect_to "/"
    else
      flash[:error] = I18n.t('user_sessions_controller.user_has_been_banned', :username => @user.username).html_safe
      redirect_to "/"
    end
  end

  def destroy
    @user_session = UserSession.find
    @user_session.destroy
    flash[:notice] = I18n.t('user_sessions_controller.logged_out')
    redirect_to root_url
  end

end
