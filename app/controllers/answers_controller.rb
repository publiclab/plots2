class AnswersController < ApplicationController
  before_action :require_user
  before_action :find_answer, except: %i(create)

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
    if @answer.uid == current_user.uid
      @answer.content = params[:body]
      flash[:notice] = @answer.save ?  'Answer updated.' : "Answer couldn't be updated."
    else
      flash[:error] = 'Only the author of the answer can edit it.'
    end

    redirect_to @answer.node.path(:question)
  end

  def delete
    if current_user.uid == @answer.node.uid || @answer.uid == current_user.uid || logged_in_as(['admin', 'moderator'])
      respond_to do |format|
        if @answer.destroy
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
    if logged_in_as(['admin', 'moderator']) || current_user.uid == @answer.node.uid
      respond_to do |format|
        if @answer.accepted
          @answer.accepted = false
          @answer.save
        else
          @answer.accepted = true
          @answer.save
          @answer.node.add_tag('answered', @answer.author)
          AnswerMailer.notify_answer_accept(@answer.author, @answer).deliver_now
        end
        @answer.reload
        format.js
      end
    else
      render plain: "Answer couldn't be accepted"
    end
  end

  private

  def find_answer
    @answer = Answer.find(params[:id])
  end
end
