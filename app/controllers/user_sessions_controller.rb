class UserSessionsController < ApplicationController

  # "publiclaboratory.org/people/"+params[:login]+"/identity"
  # http://publiclaboratory.org/people/warren/identity

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

end
