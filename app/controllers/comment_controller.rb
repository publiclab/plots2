class CommentController < ApplicationController
  include CommentHelper

  respond_to :html, :xml, :json
  before_action :require_user, only: %i(create update make_answer delete)

  def index
    status = 1 # status of comments to display
    status = 0 if current_user && (current_user.role == 'admin' || current_user.role == 'moderator')
    @comments = Comment.paginate(page: params[:page], per_page: 30)
      .order('timestamp DESC')
      .where(status: status)
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
          format.js { render 'comments/create.js.erb' }
        else
          format.html do
            if request.xhr?
              render partial: 'notes/comment', locals: { comment: @comment }
            else
              tagnames = @node.tagnames.map do |tagname|
                "<a href='/subscribe/tag/#{tagname}'>#{tagname}</a>"
              end
              tagnames = tagnames.join(', ')
              tagnames = " Click to subscribe to updates on these tags or topics: " + tagnames unless tagnames.empty?
              flash[:notice] = "Comment posted.#{tagnames}"
              redirect_to @node.path + '#last' # to last comment
            end
          end
        end
      end
    rescue CommentError
      flash[:error] = 'The comment could not be saved.'
      render plain: 'failure'
    end
  end

  def create_by_token
    @node = Node.find params[:id]
    @user = User.find_by(username: params[:username])
    @body = params[:body]
    @token = request.headers["HTTP_TOKEN"]

    if @user && @user.token == @token
      begin
        # The create_comment is a function that has been defined inside the
        # CommentHelper module inside app/helpers/comment_helper.rb and can be
        # used in here because the module was `include`d right at the beginning
        @comment = create_comment(@node, @user, @body)
        respond_to do |format|
          format.all { head :created }
        end
      rescue CommentError
        respond_to do |format|
          format.all { head :bad_request }
        end
      end
    else
      respond_to do |format|
        format.all { head :unauthorized }
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
        format.js { render template: 'comments/create' }
        format.html { render template: 'comments/create.html' }
      end
    else
      flash[:error] = 'The comment could not be saved.'
      render plain: 'failure'
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
            format.js { render 'comments/delete.js.erb' }
          else
            format.html do
              if request.xhr?
                render plain: 'success'
              else
                flash[:notice] = 'Comment deleted.'
                redirect_to '/' + @node.path
              end
            end
          end
        end
      else
        flash[:error] = 'The comment could not be deleted.'
        render plain: 'failure'
      end
    else
      prompt_login 'Only the comment or post author can delete this comment'
    end
  end

  def make_answer
    @comment = Comment.find params[:id]
    comments_node_and_path

    if @comment.uid == current_user.uid ||
       current_user.role == 'admin' ||
       current_user.role == 'moderator'

      node_id = @comment.nid.zero? ? @comment.answer.nid : @comment.nid

      @answer = Answer.new(
        nid: node_id,
        uid: @comment.uid,
        content: @comment.comment,
        created_at: @comment.created_at,
        updated_at: @comment.created_at
      )

      if @answer.save && @comment.delete
        @answer_id = @comment.aid
        respond_with do |format|
          format.js { render template: 'comments/make_answer' }
        end
      else
        flash[:error] = 'The comment could not be promoted to answer.'
        render plain: 'failure'
      end
    else
      prompt_login 'Only the comment author can promote this comment to answer'
    end
  end

  def like_comment
    @comment_id = params["comment_id"].to_i
    @user_id = params["user_id"].to_i
    @emoji_type = params["emoji_type"]
    comment = Comment.where(cid: @comment_id).first
    like = comment.likes.where(user_id: @user_id, emoji_type: @emoji_type)
    @is_liked = like.count.positive?
    if like.count.positive?
      like.first.destroy
    else
      comment.likes.create(user_id: @user_id, emoji_type: @emoji_type)
    end

    @likes = comment.likes.group(:emoji_type).count
    respond_with do |format|
      format.js do
        render template: 'comments/like_comment'
      end
    end
  end
end
