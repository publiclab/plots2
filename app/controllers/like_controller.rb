class LikeController < ApplicationController

  respond_to :html, :xml, :json
  before_filter :require_user, :only => [:create, :delete]

  # return a count of likes for a given object
  def show
    # TODO Render as JSON or something? Directly injected into element.
    if params[:node]
      DrupalNode.find(params[:node]).cached_likes
    end
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
