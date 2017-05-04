class LikeController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :require_user, only: %i[create delete]

  # return a count of likes for a given node
  # This does not support non-nodes very well
  def show
    render json: Node.find(params[:id]).cached_likes
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
    render json: set_liking(true)
  end

  # for the current user, remove the like from the given node
  def delete
    render json: set_liking(false)
  end

  private

  # this ought to go in a model, such as node_selection, and pass :uid and :nid
  # then it could also be tested independently in a unit test
  def set_liking(value)
    # scope like variable outside the transaction
    like = nil
    count = nil
    # Check like status and update like and cache in an atomic transaction
    ActiveRecord::Base.transaction do
      # Create the entry if it isn't already created.
      like = NodeSelection.where(user_id: current_user.uid,
                                 nid: params[:id]).first_or_create
      like.liking = value

      # Check if the value changed.
      if like.liking_changed?
        node = Node.find(params[:id])
        if like.liking
          # it might be good to pull this out of the transaction to reduce
          # locking time, but all these vars will have to be rescoped
          if node.type == 'note'
            SubscriptionMailer.notify_note_liked(node, like.user)
          end
          count = 1
          node.cached_likes = node.cached_likes + 1
        else
          count = -1
          node.cached_likes = node.cached_likes - 1
        end

        # Save the changes.
        node.save!
        like.save!
      end
    end

    count
  end
end
