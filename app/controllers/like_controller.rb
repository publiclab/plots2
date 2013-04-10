class LikeController < ApplicationController

  respond_to :html, :xml, :json
  before_filter :require_user, :only => [:create, :delete]

  # return a count of likes for a given node
  # This does not support non-nodes very well
  def show
    render :json => DrupalNode.find(params[:id]).cached_likes
  end

  # for the current user, return whether is presently liked or not
  def liked?
    result = NodeSelection.find_by_user_id_and_nid(current_user.uid, params[:id])
    if result.nil?
      result = false
    else
      result = result.liking
    end
    render :json => result
  end

  # for the current user, register as liking the given node
  def create
    render :json => set_liking(true)
  end

  # for the current user, remove the like from the given node
  def delete
    render :json => set_liking(false)
  end

  private

  def set_liking(value)
    # Create the entry if it isn't already created.
    like = NodeSelection.where(:user_id => current_user.uid,
                               :nid => params[:id]).first_or_create
    like.liking = value

    # Check if the value changed.
    if like.liking_changed?
      node = DrupalNode.find(params[:id])
      if like.liking
        node.cached_likes = node.cached_likes + 1
      else
        node.cached_likes = node.cached_likes - 1
      end
      
      # Save the changes.
      ActiveRecord::Base.transaction do
        node.save!
        like.save!
      end
    end

    return like.liking
  end

end
