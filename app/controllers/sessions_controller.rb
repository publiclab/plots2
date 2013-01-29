# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  # render new.erb.html
  def new
  end

  def create
    params[:openid_url] = "publiclaboratory.org/people/"+params[:login]+"/identity" if params[:login]
    open_id_authentication(params[:openid_url],params[:return_to])
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

  # only on local installations, to bypass OpenID; add "local: true" to config/config.yml
  def local
    if APP_CONFIG["local"] == true && @user = User.find_by_login(params[:login])
      self.current_user = @user
      successful_login
    else
      flash[:error] = "Forbidden"
      redirect_to "/"
    end
  end

protected

  def successful_login
    if params[:remember_me] == "1"
      self.current_user.remember_me
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
    end
    redirect_back_or_default('/') 
    flash[:notice] = "Logged in successfully"
  end

  def failed_login(message = "Authentication failed.")
    flash.now[:error] = message
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
    render :action => 'new'
  end

  def open_id_authentication(openid_url,return_to)
    return_to ||= "/dashboard"
    #authenticate_with_open_id(openid_url, :required => [:nickname, :email]) do |result, identity_url, registration|
    authenticate_with_open_id(openid_url, :required => [:nickname, :email],:return_to => "http://"+request.host+"/session?_method=post&return_to="+return_to) do |result, identity_url, registration|
      if result.successful?
        @user = User.find_or_initialize_by_identity_url(identity_url)
        if @user.new_record?
          @user.login = registration['nickname']
          @user.email = registration['email']
          @user.save(false) # bypasses validations... temporary: instead, store registration info in session, ask user to review?
        end
        self.current_user = @user
        successful_login
      else
        failed_login result.message
      end
    end
  end
end
