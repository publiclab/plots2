class LikeController < ApplicationController
  respond_to :html, :xml, :json
  before_action :require_user, only: %i(create delete)

  # list all recent likes
  def index
    @paginated = true
    @pagy_a, @likes = pagy_array(NodeSelection.all.reverse)
  end

  # return a count of likes for a given node
  # This does not support non-nodes very well
  def show
    render json: Node.find(params[:id]).likers.size
  end

  # for the current user, return whether is presently liked or not
  def liked?
    result = NodeSelection.find_by_user_id_and_nid(current_user.uid, params[:id])
    result = if result.nil?
               false
             else
               result.liking
    end
    render json: result
  end

  # for the current user, register as liking the given node
  def create
    render json: Node.like(params[:id], current_user)
  end

  # for the current user, remove the like from the given node
  def delete
    render json: Node.unlike(params[:id], current_user)
  end
end
