class UserSessionsController < ApplicationController

  def new
    @title = "Log in"
  end

  def create
    params[:user_session][:username] = params[:openid] if params[:openid] # second runthrough must preserve username 
    username = params[:user_session][:username] if params[:user_session]

    @user = User.find_by_username(username)
    # an existing native user
    if @user.drupal_user.status == 1
      if params[:user_session].nil? || @user
        if @user && @user.crypted_password.nil? # the user has not created a pwd in the new site
          #params[:user_session][:openid_identifier] = "http://localhost/people/"+username+"/identity"
          #params[:user_session][:openid_identifier] = "http://publiclaboratory.org/people/"+username+"/identity"
          params[:user_session][:openid_identifier] = "http://old.publiclab.org/people/"+username+"/identity" if username
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
              flash[:warning] = "Your account has been migrated from the old PublicLaboratory.org website; please create a password for the new site."
              redirect_to "/profile/edit"
            else
              flash[:notice] = "Successfully logged in."
              if session[:openid_return_to] # for openid login, redirects back to openid auth process
                return_to = session[:openid_return_to]
                session[:openid_return_to] = nil
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
          flash[:warning] = "It looks like you're new here! Sign up below to join."
          redirect_to "/signup"
        end
      end
    else
      flash[:error] = "The user '"+@user.username+"' has been banned; please contact <a href='mailto:web@publiclab.org'>web@publiclab.org</a> if you believe this is in error."
      redirect_to "/"
    end
  end

  def destroy
    @user_session = UserSession.find
    @user_session.destroy
    flash[:notice] = "Successfully logged out."
    redirect_to root_url
  end

end
