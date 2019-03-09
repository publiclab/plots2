class RelationshipsController < ApplicationController
  before_action :require_user

  def create
    user = User.find(params[:followed_id])
    status = 412
    unless current_user.following?(@profile_user)
      current_user.follow(user)
      status = 200
    end
    render json: { status: status }
  end

  def destroy
    relation = Relationship.where(follower_id: current_user.id, followed_id: params[:id])
    status = 412
    unless relation.nil?
      current_user.unfollow(User.find_by_id(params[:id]))
      status = 200
    end
    render json: { status: status }
  end

  private

  def require_user
    head(:unprocessable_entity) unless current_user
  end
end
