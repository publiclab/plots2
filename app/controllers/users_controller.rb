class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new({
      :username => params[:user][:username],
      :email => params[:user][:email],
      :password => params[:user][:password],
      :password_confirmation => params[:user][:password_confirmation]
    })
    if @user.save
      redirect_to root_url, :notice => "Successfully created user."
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to root_url, :notice  => "Successfully updated user."
    else
      render :action => 'edit'
    end
  end
end
