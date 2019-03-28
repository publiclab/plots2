class RelationshipsController < ApplicationController
  before_action :require_user

  def create
    user = User.find(params[:followed_id])
    current_user.follow(user)
    flash[:notice] = "You are now following #{user.username} ."
    redirect_to URI.parse("/profile/#{user.username}").path
  end

  def destroy
    user = Relationship.find(params[:id]).followed
    current_user.unfollow(user)
    redirect_to URI.parse("/profile/#{user.username}").path
  end

  private

  def require_user
    head(:unprocessable_entity) unless current_user
  end
end
