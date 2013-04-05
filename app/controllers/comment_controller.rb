class CommentController < ApplicationController

  before_filter :require_user, :only => [:create, :update, :delete]

  # handle some errors!!!!!!
  def create
    @node = DrupalNode.find params[:id]
    @comment = @node.comment({:uid => current_user.uid,:body => params[:body]})
    @comment.notify(current_user)
    flash[:notice] = "Comment posted."
    # should implement ajax too
    redirect_to "/"+@node.slug+"#last" # to last comment
  end

  def update
    @comment = DrupalComment.find params[:id]
    # should abstract ".comment" to ".body" for future migration to native db
    @comment.comment = params[:body] 
    if @comment.save
      @comment.notify(current_user)
      flash[:notice] = "Comment updated."
    else
      flash[:error] = "The comment could not be updated."
    end
    redirect_to "/"+@comment.parent.slug
  end

  def delete
    @comment = DrupalComment.find params[:id]
    if @comment.parent.uid == current_user.uid || @comment.uid == current_user.uid
      if @comment.delete
        flash[:notice] = "Comment deleted."
      else
        flash[:error] = "The comment could not be deleted."
      end
      redirect_to "/"+@comment.parent.slug
    else
      prompt_login "Only the comment or post author can delete this comment"
    end
  end

end
