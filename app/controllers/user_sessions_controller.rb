class UserSessionsController < ApplicationController

  def create
    @user_session = UserSession.new(params[:user_session])
    @user_session.save do |result|
      if result
        flash[:notice] = "Successfully logged in."
        redirect_to root_url
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
