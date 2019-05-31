class RelationshipsController < ApplicationController
  before_action :require_user

  def create
    user = User.find(params[:followed_id])
    respond_to do |format|
      if !current_user.following?(user)
        current_user.follow(user)
        format.html { redirect_to request.referrer, notice: "You have started following " + user.username }
        format.js { render "create", locals: { following: true, profile_user: user } }
      else
        format.html {
          flash[:error] = "Error in following user"
          redirect_to request.referrer
        }
        format.js { render "create", locals: { following: false, profile_user: user } }
      end
    end
  end

  def destroy
    user = User.find_by_id(params[:id])
    relation = Relationship.where(follower_id: current_user.id, followed_id: params[:id])
    respond_to do |format|
      if !relation.nil?
        current_user.unfollow(user)
        format.html { redirect_to request.referrer, notice: "You have unfollowed " + user.username }
        format.js { render "destroy", locals: { unfollowing: true, profile_user: user } }
      else
        format.html {
          flash[:error] = "Error in unfollowing user"
          redirect_to request.referrer
        }
        format.js { render "destroy", locals: { unfollowing: false, profile_user: user } }
      end
    end
  end

  private

  def require_user
    head(:unprocessable_entity) unless current_user
  end
end
