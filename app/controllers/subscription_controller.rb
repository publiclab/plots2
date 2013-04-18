# for now, adapting like_controller for just tag following. 
# We can create switches for different kinds of likes. 
# No route or view code as of yet.

class SubscriptionController < ApplicationController

  respond_to :html, :xml, :json
  before_filter :require_user, :only => [:create, :delete, :index]

  def index
    @title = "Subscriptions"
    render :template => "home/subscriptions"
  end

  # return a count of subscriptions for a given tag
  def tag_count
    render :json => TagSelection.count(params[:tid], :conditions => {:following => true})
  end

  # for the current user, return whether is presently liked or not
  def followed
    # may be trouble: there can be multiple tags with the same name, no? We can eliminate that possibility in a migration if so.
    result = TagSelection.find_by_user_id_and_tid(current_user.uid, params[:id]) if params[:type] == "tag"
    if result.nil?
      result = false
    else
      result = result.following
    end
    render :json => result
  end

  # for the current user, register as liking the given tag
  def add
    # assume tag, for now
    if params[:type] == "tag"
      id = DrupalTag.find_by_name(params[:name]).tid
    end
    # test for uniqueness, handle it as a validation error if you like
    if id.nil?
      flash[:error] = "The tag '#{params[:name]}' does not exist; there must be content tagged with it first."
      redirect_to "/subscriptions"
    elsif TagSelection.find(:all, :conditions => {:user_id => current_user.uid, :tid => id}).length > 0
      flash[:error] = "You are already subscribed to '#{params[:name]}'"
      redirect_to "/subscriptions"
    else
      if set_following(true,params[:type],id)
        respond_with do |format|
          format.html do
            if request.xhr?
              render :json => true
            else
              flash[:notice] = "You are now following '#{params[:name]}'."
              redirect_to "/subscriptions"
            end
          end
        end
      else
        flash[:error] = "Something went wrong!" # silly 
      end
    end
  end

  # for the current user, remove the like from the given tag
  def delete
    # assume tag, for now
    if params[:type] == "tag"
      id = DrupalTag.find_by_name(params[:name]).tid
    end
    if id.nil?
      flash[:error] = "You are not subscribed to '#{params[:name]}'"
      redirect_to "/subscriptions"
    else
      if set_following(false,params[:type],id)
        respond_with do |format|
          format.html do
            if request.xhr?
              render :json => true
            else
              flash[:notice] = "You have stopped following '#{params[:name]}'."
              redirect_to "/subscriptions"
            end
          end
        end
      else
        flash[:error] = "Something went wrong!" # silly 
      end
    end
  end

  private

  def set_following(value,type,id)
    # add swtich statement for different types: tag, node, user
    # type

    # Create the entry if it isn't already created.
    # assume tag, for now: 
    subscription = TagSelection.where(:user_id => current_user.uid,
                                      :tid => id).first_or_create
    subscription.following = value

    # Check if the value changed.
    if subscription.following_changed?
      tag = DrupalTag.find(id)
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
