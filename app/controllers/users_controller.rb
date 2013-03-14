class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    # craft a publiclaboratory OpenID URI around the PL username given:
    params[:user][:openid_identifier] = "http://publiclaboratory.org/people/"+params[:user][:openid_identifier]+"/identity" if params[:user]
    @user = User.new(params[:user])
    @user.save({}) do |result| # <<<<< THIS LINE WAS THE PROBLEM FOR "Undefined [] for True" error...
      if result
        flash[:notice] = "Registration successful."
        redirect_to root_url
      else
        render :action => 'new'
      end
    end
  end

  def update
    @user = current_user
    @user.attributes = params[:user]
    @user.save do |result|
      if result
        flash[:notice] = "Successfully updated profile."
        redirect_to root_url
      else
        render :action => 'edit'
      end
    end
  end

  def edit
    @user = User.find(params[:id])
  end

end
