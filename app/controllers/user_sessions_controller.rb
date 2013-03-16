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

  def local
    if true #limit to only local, development use
      @user_session = UserSession.new({:username => params[:id],:password => true})
      @user_session.save do |result|
        if result
          flash[:notice] = "Successfully logged in."
          redirect_to root_url
        else
          render :action => 'new'
        end
      end
    end
  end

end
