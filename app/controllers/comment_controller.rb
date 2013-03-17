class CommentController < ApplicationController

  def create
    if current_user
      @node = DrupalNode.find params[:id]
      @comment = @node.comment({:uid => current_user.uid,:body => params[:body]})
      flash[:notice] = "Comment posted."
      # should implement ajax too
      redirect_to "/"+@node.slug+"#last" # to last comment
    else
      prompt_login "You must be logged in to comment."
    end
  end

  def update
    if current_user
      @comment = DrupalComment.find params[:id]
      # should abstract ".comment" to ".body" for future migration to native db
      @comment.comment = params[:body] 
      if @comment.save
        @comment.notify
        flash[:notice] = "Comment updated."
      else
        flash[:error] = "The comment could not be updated."
      end
      redirect_to "/"+@comment.parent.slug
    else
      prompt_login "You must be logged in to edit comments."
    end
  end

  def delete
    if current_user
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
    else
      prompt_login "You must be logged in to delete comments."
    end
  end

end
