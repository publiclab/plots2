class RelationshipsController < ApplicationController
  before_filter :require_user

  def create
    user = User.find(params[:followed_id])
    current_user.follow(user)
    redirect_to "/profile/#{user.username}"
  end

  def destroy
    user = Relationship.find(params[:id]).followed
    current_user.unfollow(user)
    redirect_to "/profile/#{user.username}"
  end

  private

  def require_user
    head(:unprocessable_entity) unless current_user
  end
end
