class CommentController < ApplicationController
  include CommentHelper

  respond_to :html, :xml, :json
  before_filter :require_user, only: %i[create update delete]

  def index
    @comments = Comment.paginate(page: params[:page], per_page: 30)
                       .order('timestamp DESC')
    render template: 'comments/index'
  end

  # handle some errors!!!!!!
  # create node comments
  def create
    @node = Node.find params[:id]
    @body = params[:body]
    @user = current_user

    begin
      @comment = create_comment(@node, @user, @body)
      respond_with do |format|
        if params[:type] && params[:type] == 'question'
          @answer_id = 0
          format.js
        else
          format.html do
            if request.xhr?
              render partial: 'notes/comment', locals: { comment: @comment }
            else
              flash[:notice] = 'Comment posted.'
              redirect_to @node.path + '#last' # to last comment
            end
          end
        end
      end
    rescue CommentError
      flash[:error] = 'The comment could not be saved.'
      render text: 'failure'
    end
  end

  def create_by_token
    @node = Node.find params[:id]
    @user = User.find_by_username params[:username]
    @body = params[:body]
    @token = request.headers["HTTP_TOKEN"]

    if @user && @user.token == @token
      begin
        # The create_comment is a function that has been defined inside the
        # CommentHelper module inside app/helpers/comment_helper.rb and can be
        # used in here because the module was `include`d right at the beginning
        @comment = create_comment(@node, @user, @body)
        respond_to do |format|
          format.all { render :nothing => true, :status => :created }
        end
      rescue CommentError
        respond_to do |format|
          format.all { render :nothing => true, :status => :bad_request }
        end
      end
    else
      respond_to do |format|
        format.all { render :nothing => true, :status => :unauthorized }
      end
    end
  end

  # create answer comments
  def answer_create
    @answer_id = params[:aid]
    @comment = Comment.new(
      uid: current_user.uid,
      aid: params[:aid],
      comment: params[:body],
      timestamp: Time.now.to_i
    )
    if @comment.save
      @comment.answer_comment_notify(current_user)
      respond_to do |format|
        format.js { render template: 'comment/create' }
      end
    else
      flash[:error] = 'The comment could not be saved.'
      render text: 'failure'
    end
  end

  def create_inline_comment
    @node = Node.find params[:id]
    @body = params[:body]
    @subsection_string = params[:subsection_string]

    @comment = Comment.new(
      nid: @node.id,
      uid: current_user.uid,
      comment: @body,
      reference: @subsection_string,
      timestamp: Time.now.to_i
    )
    if @comment.save
      respond_to do |format|
        format.js { render json: @comment }
      end
    else
      flash[:error] = 'The comment could not be saved.'
      render text: 'failure'
    end
  end

  def inline_comments
    reference = params[:reference]
    @inline_comments = Comment.where("reference = ?", reference)
    respond_to do |format|
      format.js { render json: @inline_comments }
    end
  end

  def update
    @comment = Comment.find params[:id]

    comments_node_and_path

    if @comment.uid == current_user.uid
      # should abstract ".comment" to ".body" for future migration to native db
      @comment.comment = params[:body]
      if @comment.save
        flash[:notice] = 'Comment updated.'
        redirect_to @path + '?_=' + Time.now.to_i.to_s
      else
        flash[:error] = 'The comment could not be updated.'
        redirect_to @path
      end
    else
      flash[:error] = 'Only the author of the comment can edit it.'
      redirect_to @path
    end
  end

  def delete
    @comment = Comment.find params[:id]

    comments_node_and_path

    if current_user.uid == @node.uid ||
       @comment.uid == current_user.uid ||
       current_user.role == 'admin' ||
       current_user.role == 'moderator'

      if @comment.delete
        respond_with do |format|
          if params[:type] && params[:type] == 'question'
            @answer_id = @comment.aid
            format.js
          else
            format.html do
              if request.xhr?
                render text: 'success'
              else
                flash[:notice] = 'Comment deleted.'
                redirect_to '/' + @node.path
              end
            end
          end
        end
      else
        flash[:error] = 'The comment could not be deleted.'
        render text: 'failure'
      end
    else
      prompt_login 'Only the comment or post author can delete this comment'
    end
  end
end
