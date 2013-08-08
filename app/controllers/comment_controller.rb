class CommentController < ApplicationController

  respond_to :html, :xml, :json
  before_filter :require_user, :only => [:create, :update, :delete]

  # handle some errors!!!!!!
  def create
    @node = DrupalNode.find params[:id]
    @comment = @node.add_comment({:uid => current_user.uid,:body => params[:body]})
    if current_user && @comment.save!
      @comment.notify(current_user)
      respond_with do |format|
        format.html do
          if request.xhr?
            render :partial => "notes/comment", :locals => {:comment => @comment}
          else
            flash[:notice] = "Comment posted."
            redirect_to @node.path+"#last" # to last comment
          end
        end
      end
    else
      flash[:error] = "The comment could not be saved."
    end
  end
     
  def update
    @comment = DrupalComment.find params[:id]
    if @comment.uid == current_user.uid
      # should abstract ".comment" to ".body" for future migration to native db
      @comment.comment = params[:body] 
      if @comment.save
        @comment.notify(current_user)
        flash[:notice] = "Comment updated."
      else
        flash[:error] = "The comment could not be updated."
      end
      redirect_to "/"+@comment.parent.slug
    else
      flash[:error] = "Only the author of the comment can edit it."
    end
  end

  def delete
    @comment = DrupalComment.find params[:id]
    if current_user.uid == @comment.parent.uid || @comment.uid == current_user.uid || current_user.role == "admin" || current_user.role == "moderator"
      if @comment.delete
        respond_with do |format|
          format.html do
            if request.xhr?
              render :text => "success"
            else
              flash[:notice] = "Comment deleted."
              redirect_to "/"+@comment.parent.slug
            end
          end
        end
      else
        flash[:error] = "The comment could not be deleted."
        redirect_to "/"+@comment.parent.slug
      end
    else
      prompt_login "Only the comment or post author can delete this comment"
    end
  end

end
