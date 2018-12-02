class UserSessionsController < ApplicationController
  before_action :require_no_user, :only => [:new]
  def new
    @title = I18n.t('user_sessions_controller.log_in')
  end

  def create
    auth = request.env['omniauth.auth']
    if auth
      # User successfully completed oauth signin on third-party
      handle_social_login_flow(auth)
    else
      # User clicked on login button on site
      handle_site_login_flow
    end
  end

  def handle_social_login_flow(auth)
    # Find an identity here
    @identity = UserTag.find_with_omniauth(auth)
    return_to = request.env['omniauth.origin'] || root_url
    return_to += '?_=' + Time.now.to_i.to_s

    if signed_in?
      if @identity.nil?
        # If no identity was found, create a brand new one here
        @identity = UserTag.create_with_omniauth(auth, current_user.id)
        # The identity is not associated with the current_user so lets
        # associate the identity
        @identity.user = current_user
        @identity.save
        redirect_to return_to, notice: "Successfully linked to your account!"
      elsif @identity.user == current_user
        # User is signed in so they are trying to link an identity with their
        # account. But we found the identity and the user associated with it
        # is the current user. So the identity is already associated with
        # this user. So let's display an error message.
        redirect_to return_to, notice: "Already linked to your account!"
      else
        # User is signed in so they are trying to link an identity with their
        # account. But we found the identity and a different user associated with it
        # ,which is not the current user. So the identity is already associated with
        # that user. So let's display an error message.
        redirect_to return_to, notice: "Already linked to another account!"
      end
    else # not signed in
      if @identity&.user.present?
        # The identity we found had a user associated with it so let's
        # just log them in here
        @user = @identity.user
        @user_session = UserSession.create(@identity.user)
        redirect_to return_to, notice: "Signed in!"
      else # identity does not exist so we need to either create a user with identity OR link identity to existing user
        if User.where(email: auth["info"]["email"]).empty?
          # Create a new user as email provided is not present in PL database
          user = User.create_with_omniauth(auth)
          WelcomeMailer.notify_newcomer(user).deliver_now
          @identity = UserTag.create_with_omniauth(auth, user.id)
          key = user.generate_reset_key
          @user_session = UserSession.create(@identity.user)
          @user = user
          # send key to user email
          PasswordResetMailer.reset_notify(user, key).deliver_now unless user.nil? # respond the same to both successes and failures; security
          redirect_to return_to, notice: "You have successfully signed in. Please change your password via a link sent to you via e-mail"
        else # email exists so link the identity with existing user and log in the user
          user = User.where(email: auth["info"]["email"])
          # If no identity was found, create a brand new one here
          @identity = UserTag.create_with_omniauth(auth, user.ids.first)
          # The identity is not associated with the current_user so lets
          # associate the identity
          @identity.save
          @user = user
          # log in them
          @user_session = UserSession.create(@identity.user)
          redirect_to return_to, notice: "Successfully linked to your account!"
        end
      end
    end
  end

  def handle_site_login_flow
    username = params[:user_session][:username] if params[:user_session]
    u = User.find_by(username: username)
    if u && u.password_checker != 0
      n = u.password_checker
      hash = { 1 => "Facebook", 2 => "Github", 3 => "Google", 4 => "Twitter"  }
      s = "This account doesn't have a password set. It may be logged in with " + hash[n] + " account, or you can set a new password via Forget password feature"
      flash[:error] = s
      redirect_to '/'
    else
      params[:user_session][:username] = params[:openid] if params[:openid] # second runthrough must preserve username
      @user = User.find_by(username: username)
      # try finding by email, if that exists
      if @user.nil? && !User.where(email: username).empty?
        @user = User.find_by(email: username)
        params[:user_session][:username] = @user.username
      end
      if @user.nil?
        flash[:warning] = "There is nobody in our system by that name, are you sure you have the right username?"
        redirect_to '/login'
      elsif params[:user_session].nil? || @user&.drupal_user&.status == 1
        # an existing Rails user
        if params[:user_session].nil? || @user
          if @user&.crypted_password.nil? # the user has not created a pwd in the new site
            params[:user_session][:openid_identifier] = 'https://old.publiclab.org/people/' + username + '/identity' if username
            params[:user_session].delete(:password)
            params[:user_session].delete(:username)
            params[:openid] = username # pack up username for second runthrough
          end
          @user_session = UserSession.new(username: params[:user_session][:username],
                                          password: params[:user_session][:password],
                                          remember_me: params[:user_session][:remember_me])
          saved = @user_session.save do |result|
            if result
              # replace this with temporarily saving pwd in session,
              # and automatically saving it in the user record after login is completed
              if current_user.crypted_password.nil? # the user has not created a pwd in the new site
                flash[:warning] = I18n.t('user_sessions_controller.create_password_for_new_site')
                redirect_to '/profile/edit'
              else
                flash[:notice] = I18n.t('user_sessions_controller.logged_in')
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
                  redirect_to '/dashboard'
                end
              end
            else
              # Login failed; probably bad password.
              # Errors will display on login form:
              render action: 'new'
            end
          end
        else # not a native user
          if !DrupalUser.find_by(name: username).nil?
            # this is a user from the old site who hasn't registered on the new site
            redirect_to controller: :users, action: :create, user: { openid_identifier: username }
          else # totally new user!
            flash[:warning] = I18n.t('user_sessions_controller.sign_up_to_join')
            redirect_to '/signup'
          end
        end
      elsif params[:user_session].nil? || @user&.drupal_user&.status == 5
        flash[:error] = I18n.t('user_sessions_controller.user_has_been_moderated', username: @user.username).html_safe
        redirect_to '/'
      else
        flash[:error] = I18n.t('user_sessions_controller.user_has_been_banned', username: @user.username).html_safe
        redirect_to '/'
      end
    end
  end

  def destroy
    @user_session = UserSession.find
    @user_session.destroy
    flash[:notice] = I18n.t('user_sessions_controller.logged_out')
    redirect_to '/' + '?_=' + Time.now.to_i.to_s
  end

  def logout_remotely
    current_user.reset_persistence_token!
    flash[:notice] = I18n.t('user_sessions_controller.logged_out')
    redirect_to '/' + '?_=' + Time.now.to_i.to_s
  end
end
