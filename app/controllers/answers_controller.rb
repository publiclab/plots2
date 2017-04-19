class AnswersController < ApplicationController
  before_filter :require_user

  def create
    @node = Node.find(params[:nid])
    @answer = Answer.new(
      nid: @node.id,
      uid: current_user.uid,
      content: params[:body]
    )
    respond_to do |format|
      if current_user && @answer.save
        @answer.answer_notify(current_user)
        format.html { redirect_to @node.path(:question), notice: 'Answer successfully posted' }
        format.js {}
      end
    end
  end

  def update
    @answer = Answer.find(params[:id])
    if @answer.uid == current_user.uid
      @answer.content = params[:body]
      if @answer.save
        flash[:notice] = 'Answer updated'
        redirect_to @answer.node.path(:question)
      else
        flash[:error] = "Answer couldn't be updated"
        redirect_to @answer.node.path(:question)
      end
    else
      flash[:error] = 'Only the author of the answer can edit it.'
      redirect_to @answer.node.path(:question)
    end
  end

  def delete
    @answer = Answer.find(params[:id])
    if current_user.uid == @answer.node.uid ||
       @answer.uid == current_user.uid ||
       current_user.role == 'admin' ||
       current_user.role == 'moderator'
      respond_to do |format|
        if @answer.delete
          format.html { redirect_to @answer.node.path(:question), notice: 'Answer deleted' }
          format.js
        else
          flash[:error] = "The answer couldn't be deleted"
          redirect_to @answer.node.path(:question)
        end
      end
    else
      prompt_login 'Only the answer or question author can delete this answer'
    end
  end

  def accept
    @answer = Answer.find(params[:id])

    if current_user.uid == @answer.node.uid
      respond_to do |format|
        if @answer.accepted
          @answer.accepted = false
          @answer.save
        else
          @answer.accepted = true
          @answer.save
          AnswerMailer.notify_answer_accept(@answer.author, @answer).deliver
        end
        @answer.reload
        format.js
      end
    else
      render text: "Answer couldn't be accepted"
    end
  end
end
