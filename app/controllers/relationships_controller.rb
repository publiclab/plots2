class RelationshipsController < ApplicationController
  before_action :require_user

  def create
    user = User.find(params[:followed_id])
    respond_to do |format|
      if !current_user.following?(user)
        current_user.follow(user)
        format.html {
          flash[:notice] = "You have started following " + user.username
          redirect_to request.referrer
        }
        format.js {render "like/create", :locals => {:following => true, :profile_user => user}}
      else
        format.html {
          flash[:error] = "Invalid request!"
          redirect_to request.referrer
        }
        format.js {render "like/create", :locals => {:following => false, :profile_user => user}}
      end
    end
  end

  def destroy
    user = User.find_by_id(params[:id])
    relation = Relationship.where(follower_id: current_user.id, followed_id: params[:id])
    respond_to do |format|
      if !relation.nil?
        current_user.unfollow(user)
        format.html {
          flash[:notice] = "You have unfollowed " + user.username
          redirect_to request.referrer
        }
        format.js {render "like/destroy", :locals => {:unfollowing => true, :profile_user => user}}
      else
        format.html {
          flash[:error] = "Invalid request!"
          redirect_to request.referrer
        }
        format.js {render "like/destroy", :locals => {:unfollowing => false, :profile_user => user}}
      end
    end
  end

  private

  def require_user
    head(:unprocessable_entity) unless current_user
  end
end
