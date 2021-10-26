class UserSessionsController < ApplicationController
  before_action :require_no_user, only: [:new]
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

    hash_params = ""

    unless params[:hash_params].to_s.empty?
      hash_params = URI.parse("#" + params[:hash_params]).to_s
    end
    if signed_in?
      if @identity.nil?
        # If no identity was found, create a brand new one here
        @identity = UserTag.create_with_omniauth(auth, current_user.id)
        # The identity is not associated with the current_user so lets
        # associate the identity
        @identity.user = current_user
        @identity.save

        redirect_to return_to + hash_params, notice: "Successfully linked to your account!"
      elsif @identity.user == current_user
        # User is signed in so they are trying to link an identity with their
        # account. But we found the identity and the user associated with it
        # is the current user. So the identity is already associated with
        # this user. So let's display an error message.
        redirect_to return_to + hash_params, notice: "Already linked to your account!"
      else
        # User is signed in so they are trying to link an identity with their
        # account. But we found the identity and a different user associated with it
        # ,which is not the current user. So the identity is already associated with
        # that user. So let's display an error message.
        redirect_to return_to + hash_params, notice: "Already linked to another account!"
      end
    else # not signed in
      if auth["info"]["email"].nil?
        flash[:error] = "You have tried using a Twitter account with no associated email address. Unfortunately we need an email address; please add one and try again, or sign up a different way. Thank you!"
        redirect_to return_to
      else
        # User U has Provider P linked to U. U has email E1 while P has email E2. So, User table can't find E2 provided
        # from auth hash, hence U is found by the user of identity having E2 as email
        @user = User.where(email: auth["info"]["email"]) ? User.find_by(email: auth["info"]["email"]) : @identity.user
        if @user&.status&.zero?
          flash[:error] = I18n.t('user_sessions_controller.user_has_been_banned', username: @user.username).html_safe
          redirect_to return_to + hash_params
        elsif @user&.status == 5
          flash[:error] = I18n.t('user_sessions_controller.user_has_been_moderated', username: @user.username).html_safe
          redirect_to return_to + hash_params
        elsif @identity&.user.present?
          # The identity we found had a user associated with it so let's
          # just log them in here
          @user = @identity.user
          @user_session = UserSession.create(@identity.user)
          if session[:openid_return_to] # for openid login, redirects back to openid auth process
            return_to = session[:openid_return_to]
            session[:openid_return_to] = nil
            redirect_to return_to + hash_params
          else
            redirect_to return_to + hash_params, notice: I18n.t('user_sessions_controller.logged_in')
          end
        else # identity does not exist so we need to either create a user with identity OR link identity to existing user
          if User.where(email: auth["info"]["email"]).empty?
            # Create a new user as email provided is not present in PL database
            user = User.create_with_omniauth(auth)
            WelcomeMailer.notify_newcomer(user).deliver_later
            @identity = UserTag.create_with_omniauth(auth, user.id)
            key = user.generate_reset_key
            @user_session = UserSession.create(@identity.user)
            @user = user
            # send key to user email
            PasswordResetMailer.reset_notify(user, key).deliver_later unless user.nil? # respond the same to both successes and failures; security
            if session[:openid_return_to] # for openid login, redirects back to openid auth process
              return_to = session[:openid_return_to]
              session[:openid_return_to] = nil
              redirect_to return_to + hash_params
            elsif params[:return_to] && params[:return_to].split('/')[0..3] == ["", "subscribe", "multiple", "tag"]
              flash[:notice] = "You are now following '#{params[:return_to].split('/')[4]}'."
              subscribe_multiple_tag(params[:return_to].split('/')[4])
              redirect_to '/dashboard', notice: "You have successfully signed in. Please change your password using the link sent to you via e-mail."
            else
              redirect_to '/dashboard', notice: "You have successfully signed in. Please change your password using the link sent to you via e-mail."
            end
          else # email exists in user db so link the identity with existing user and log in the user
            user = User.where(email: auth["info"]["email"])
            # If no identity was found, create a brand new one here
            @identity = UserTag.create_with_omniauth(auth, user.ids.first)
            # The identity is not associated with the current_user so lets
            # associate the identity
            @identity.save
            @user = user
            # log in them
            @user_session = UserSession.create(@identity.user)
            if session[:openid_return_to] # for openid login, redirects back to openid auth process
              return_to = session[:openid_return_to]
              session[:openid_return_to] = nil
              redirect_to return_to + hash_params
            else
              redirect_to return_to + hash_params, notice: "Successfully linked to your account!"
            end
          end
        end
      end
    end
  end

  def handle_site_login_flow
    username = params[:user_session][:username] if params[:user_session]
    u = User.find_by(username: username) || User.find_by(email: username)
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
        redirect_to params[:return_to] || '/login'
      elsif params[:user_session].nil? || @user&.status == 1
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
          @user_session.save do |result|
            if result
              hash_params = ""

              unless params[:hash_params].to_s.empty?
                hash_params = URI.parse("#" + params[:hash_params]).to_s
              end

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
                  redirect_to return_to + hash_params
                elsif session[:return_to]
                  # if url == /login?return_to=/subscribe/multiple/tag/tag1,tag299 then
                  # session[:return_to] == /subscriptions  + '?_=' + Time.current.to_i.to_s ? true
                  if params[:return_to]
                    # params[:return_to] == /login?return_to=/subscribe/multiple/tag/tag1,tag299 ? true
                    return_to = '/' + params[:return_to].split('/')[2..-1].join('/') #== /subscribe/multiple/tag/tag1,tag299
                    redirect_to return_to
                  else
                    return_to = session[:return_to]
                    if return_to == '/login'
                      return_to = '/dashboard'
                    end
                    session[:return_to] = nil
                    redirect_to return_to + hash_params
                  end
                elsif params[:return_to]
                  redirect_to params[:return_to] + hash_params
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
          flash[:warning] = I18n.t('user_sessions_controller.sign_up_to_join')
          redirect_to '/signup'
        end
      elsif params[:user_session].nil? || @user&.status == 5
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
    @user_session&.destroy
    flash[:notice] = I18n.t('user_sessions_controller.logged_out')
    prev_uri = URI(request.referer || "").path
    redirect_to prev_uri + '?_=' + Time.current.to_i.to_s
  end

  def logout_remotely
    current_user&.reset_persistence_token!
    flash[:notice] = I18n.t('user_sessions_controller.logged_out')
    prev_uri = URI(request.referer || "").path
    redirect_to prev_uri + '?_=' + Time.current.to_i.to_s
  end

  def index
    redirect_to '/dashboard'
  end

  private

  def subscribe_multiple_tag(tag_list)
    if !tag_list || tag_list == ''
      flash[:notice] = "Please enter tags for subscription in the url."
    else
      if tag_list.is_a? String
        tag_list = tag_list.split(',')
      end
      tag_list.each do |t|
        next unless t.length.positive?
        tag = Tag.find_by(name: t)
        unless tag.present?
          tag = Tag.new(
            vid: 3, # vocabulary id
            name: t,
            description: "",
            weight: 0
          )
          begin
            tag.save!
            rescue ActiveRecord::RecordInvalid
            flash[:error] = tag.errors.full_messages
            redirect_to "/subscriptions" + "?_=" + Time.now.to_i.to_s
            return false
          end
        end
        # test for uniqueness
        unless TagSelection.where(following: true, user_id: current_user.uid, tid: tag.tid).length.positive?
        # Successfully we have added subscription
          if Tag.find_by(tid: tag.tid)
            # Create the entry if it isn't already created.
            # assume tag, for now:
            subscription = TagSelection.where(user_id: current_user.uid,
                                              tid: tag.tid).first_or_create
            subscription.following = true
            # Check if the value changed.
            if subscription.following_changed?
              subscription.save!
            end
          else
            flash.now[:error] = "Sorry! There was an error in tag subscriptions. Please try it again."
          end
        end
      end
    end
  end
end
