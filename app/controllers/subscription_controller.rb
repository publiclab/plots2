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

  def stats
    @tags = {}
    TagSelection.find(:all, :conditions => {:following => true}).each do |tag|
      @tags[tag.name] = @tags[tag.name] || 0
      @tags[tag.name] += 1
    end
    render :text => @tags.inspect
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
    if current_user
      # assume tag, for now
      if params[:type] == "tag"
        tag = DrupalTag.find_by_name(params[:name])
        if tag.nil?
          # if the tag doesn't exist, we should create it!
          # this could fail validations; error out if so... 
          tag = DrupalTag.new({
            :vid => 3, # vocabulary id
            :name => params[:name],
            :description => "",
            :weight => 0})
          unless tag.save! 
            flash[:error] = "There was an error and your subscription failed. Please contact web@publiclab.org."
            redirect_to "/subscriptions"
          end
        end
        # test for uniqueness, handle it as a validation error if you like
        if TagSelection.find(:all, :conditions => {:user_id => current_user.uid, :tid => tag.tid}).length > 0
          flash[:error] = "You are already subscribed to '#{params[:name]}'"
          redirect_to "/subscriptions"
        else
          if set_following(true,params[:type],tag.tid)
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
      else
        flash[:warning] = "You must be logged in to subscribe for email updates; please <a href='javascript:void()' onClick='login()'>log in</a> or <a href='/signup'>create an account</a>."
        redirect_to "/tag/"+params[:name]
      end
    else
      # user or node subscription

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
      if !set_following(false,params[:type],id) #should return false if result is that following == false
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
        redirect_to "/subscriptions"
      end
    end
  end

  private

  def set_following(value,type,id)
    # add swtich statement for different types: tag, node, user
    if type == 'tag' && DrupalTag.find_by_tid(id)
      # Create the entry if it isn't already created.
      # assume tag, for now: 
      subscription = TagSelection.where(:user_id => current_user.uid,
                                        :tid => id).first_or_create
      subscription.following = value
 
      # Check if the value changed.
      if subscription.following_changed?
        #tag = DrupalTag.find(id)
        # we have to implement caching for tags if we want to adapt this code:
        #if subscription.following
        #  node.cached_likes = node.cached_likes + 1
        #else
        #  node.cached_likes = node.cached_likes - 1
        #end
        
        # Save the changes.
        #ActiveRecord::Base.transaction do
        #  tag.save!
          subscription.save!
        #end
      end
 
      return subscription.following
    else
      flash[:error] = "There was an error."
      return false
    end
  end

end
