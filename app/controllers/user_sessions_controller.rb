class UserSessionsController < ApplicationController

  def create
    params[:user_session][:openid_identifier] = "http://publiclaboratory.org/people/"+params[:user_session][:openid_identifier]+"/identity" if params[:user_session]
    @user_session = UserSession.new(params[:user_session])
    @user_session.save do |result|
      if result
        flash[:notice] = "Successfully logged in."
        redirect_to "/dashboard"
      else
        render :action => 'new'
      end
    end
  end

  def destroy
    @user_session = UserSession.find
    @user_session.destroy
    flash[:notice] = "Successfully logged out."
    redirect_to root_url
  end

  # this doesn't actually work, so whatever. 
  # the authlogic-oid (openID) code makes bypassing password authentication very tough, haven't cracked it
  def local
    if APP_CONFIG["local"] #limit to only local, development use
      
      @user_session = UserSession.new({:username => params[:id]})
      @user_session.save do |result|
        if result
          flash[:notice] = "Successfully logged in."
          redirect_to root_url
        else
          render :action => 'new'
        end
      end
    else
      redirect_to "/"
    end
  end

end
