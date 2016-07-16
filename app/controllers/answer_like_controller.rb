class AnswerLikeController < ApplicationController
  before_filter :require_user, :only => :likes

  def show
    render :json => Answer.find(params[:id]).cached_likes
  end

  def likes
    @answer = Answer.find(params[:aid])
    if @answer.liked_by(current_user.uid)
      AnswerSelection.set_likes(current_user.uid, @answer.id, false)
    else
      AnswerSelection.set_likes(current_user.uid, @answer.id, true)
      user = User.find(current_user.uid)
      AnswerMailer.notify_answer_like(user, @answer).deliver
    end
    @answer.reload
    respond_to do |format|
      format.js{}
    end
  end
end
