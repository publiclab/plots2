class LikeController < ApplicationController

  respond_to :html, :xml, :json
  before_filter :require_user, :only => [:create, :delete]

  # return a count of likes for a given node
  def shownode
    render :json => DrupalNode.find(params[:id]).cached_likes
  end

  # for the current user, return whether is presently liked or not
  def liked
  end

  # for the current user, register as liking the given node
  def create
  end

  # for the current user, remove the like from the given node
  def delete
  end

end
