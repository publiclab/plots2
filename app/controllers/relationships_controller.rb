class RelationshipsController < ApplicationController
  before_action :require_user

  def create
    user = User.find(params[:followed_id])
    payload = {}
    status = 500
    if current_user.following?(@profile_user)
      payload[:message] = "You already follow this user"
    else
      current_user.follow(user)
      payload[:message] = "You started following #{user.username}"
      status = 200
    end
    render :json => payload, :status => status
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
