# for now, adapting like_controller for just tag following. 
# We can create switches for different kinds of likes. 
# No route or view code as of yet.

class SubscriptionController < ApplicationController

  respond_to :html, :xml, :json
  before_filter :require_user, :only => [:create, :delete]

  # return a count of subscriptions for a given tag
  def tag_count
    render :json => TagSelection.count(params[:tid], :conditions => {:following => true})
  end

  # for the current user, return whether is presently liked or not
  def tag_followed?
    # may be trouble: there can be multiple tags with the same name, no? We can eliminate that possibility in a migration if so.
    result = TagSelection.find_by_user_id_and_tid(current_user.uid, params[:id])
    if result.nil?
      result = false
    else
      result = result.following
    end
    render :json => result
  end

  # for the current user, register as liking the given node
  def tag_create
    render :json => set_following(true)
  end

  # for the current user, remove the like from the given node
  def tag_delete
    render :json => set_following(false)
  end

  private

  def set_following(value)
    # Create the entry if it isn't already created.
    subscription = TagSelection.where(:user_id => current_user.uid,
                               :tid => params[:id]).first_or_create
    subscription.following = value

    # Check if the value changed.
    if subscription.following_changed?
      tag = DrupalTag.find(params[:id])
      # we have to implement caching for tags if we want to adapt this code:
      #if subscription.following
      #  node.cached_likes = node.cached_likes + 1
      #else
      #  node.cached_likes = node.cached_likes - 1
      #end
      
      # Save the changes.
      ActiveRecord::Base.transaction do
        tag.save!
        subscription.save!
      end
    end

    return subscription.following
  end

end
