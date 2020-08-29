class CommentController < ApplicationController
  include CommentHelper
  respond_to :html, :xml, :json
  before_action :require_user, only: %i(create update delete)

  def index
    comments = Comment.joins(:node, :user)
                   .order('timestamp DESC')
                   .where('node.status = ?', 1)
                   .paginate(page: params[:page], per_page: 30)

    @normal_comments = comments.where('comments.status = 1')
    if logged_in_as(%w(admin moderator))
      @moderated_comments = comments.where('comments.status = 4')
    end

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

      if params[:reply_to].present?
        @comment.reply_to = params[:reply_to].to_i
        @comment.save
      end

      respond_to do |format|
        @answer_id = 0
        format.js do
          render 'comments/create'
        end
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
       logged_in_as(%w(admin moderator))

      if @comment.destroy
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

  def like_comment
    @comment_id = params["comment_id"].to_i
    @user_id = params["user_id"].to_i
    @emoji_type = params["emoji_type"]
    comment = Comment.where(cid: @comment_id).first
    like = comment.likes.where(user_id: @user_id, emoji_type: @emoji_type)
    @is_liked = like.size.positive?
    if like.size.positive?
      like.first.destroy
    else
      comment.likes.create(user_id: @user_id, emoji_type: @emoji_type)
    end

    @likes = comment.likes.group(:emoji_type).size
    @user_reactions_map = comment.user_reactions_map
    respond_with do |format|
      format.js do
        render template: 'comments/like_comment'
      end
    end
  end
end
