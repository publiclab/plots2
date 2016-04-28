class CommentController < ApplicationController

  respond_to :html, :xml, :json
  before_filter :require_user, :only => [:create, :update, :delete]

  def index
    @comments = DrupalComment.paginate(page: params[:page], per_page: 30)
    render template: 'comments/index'
  end

  # handle some errors!!!!!!
  # create node comments
  def create
    @node = DrupalNode.find params[:id]
    @comment = @node.add_comment({:uid => current_user.uid,:body => params[:body]})
    if current_user && @comment.save
      @comment.notify(current_user)
      respond_with do |format|
        if params[:type] && params[:type] == 'question'
          @answer_id = 0
          format.js
        else
          format.html do
            if request.xhr?
              render :partial => "notes/comment", :locals => {:comment => @comment}
            else
              flash[:notice] = "Comment posted."
              redirect_to @node.path+"#last" # to last comment
            end
          end
        end
      end
    else
      flash[:error] = "The comment could not be saved."
      render :text => "failure"
    end
  end

  # create answer comments
  def answer_create
    @answer_id = params[:aid]
    @comment = DrupalComment.new(
      uid: current_user.uid,
      aid: params[:aid],
      comment: params[:body],
      timestamp: Time.now.to_i
    )
    if @comment.save
      @comment.answer_comment_notify(current_user)
      respond_to do |format|
        format.js { render template: "comment/create" }
      end
    else
      flash[:error] = "The comment could not be saved."
      render :text => "failure"
    end
  end

  def update
    @comment = DrupalComment.find params[:id]
    
    comments_node_and_path

    if @comment.uid == current_user.uid
      # should abstract ".comment" to ".body" for future migration to native db
      @comment.comment = params[:body]
      if @comment.save
        redirect_to @path
        flash[:notice] = "Comment updated."
      else
        redirect_to @path
        flash[:error] = "The comment could not be updated."
      end 
    else
      redirect_to @path
      flash[:error] = "Only the author of the comment can edit it."
    end
  end

  def delete
    @comment = DrupalComment.find params[:id]

    comments_node_and_path

    if current_user.uid == @node.uid ||
      @comment.uid == current_user.uid ||
      current_user.role == "admin" ||
      current_user.role == "moderator"

      if @comment.delete
        respond_with do |format|
          if params[:type] && params[:type] == 'question'
            @answer_id = @comment.aid
            format.js
          else
            format.html do
              if request.xhr?
                render :text => "success"
              else
                flash[:notice] = "Comment deleted."
                redirect_to "/"+@node.path
              end
            end
          end
        end
      else
        flash[:error] = "The comment could not be deleted."
        render :text => "failure"
      end
    else
      prompt_login "Only the comment or post author can delete this comment"
    end
  end

end
