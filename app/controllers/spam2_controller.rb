class Spam2Controller < ApplicationController
  before_action :require_user, only: %i(_spam _spam_revisions _spam_comments)

  def _spam
    if logged_in_as(%w(moderator admin))
      @nodes = Node.paginate(page: params[:page], per_page: params[:pagination])
      @nodes = case params[:type]
                 when 'wiki'
                   @nodes.where(type: 'page', status: 1).order('changed DESC')
                 when 'unmoderated'
                   @nodes.where(status: 4).order('changed DESC')
                  when 'published'
                    @nodes.where(status: 1).order('changed DESC')
                 when 'spammed'
                   @nodes.where(status: 0).order('changed DESC')
                 when 'created'
                   @nodes.where(status: [0, 4]).order('created DESC')
                 else
                   @nodes.where(status: [0, 4]).order('changed DESC')
                 end
    else
      flash[:error] = 'Only moderators can moderate posts.'
      redirect_to '/dashboard'
    end
  end

  def _spam_flags
    if logged_in_as(%w(moderator admin))
      @flags = Node.where('flag > ?', 0)
                   .order('flag DESC')
                   .paginate(page: params[:page], per_page: params[:pagination])
      @flags = case params[:type]
               when 'unmoderated'
                 @flags.where(status: 4)
               when 'spammed'
                 @flags.where(status: 0)
               when 'page'
                 @flags.where(type: 'page')
               when 'note'
                 @flags.where(type: 'node')
               else
                 @flags
               end
      render template: 'spam2/_spam'
    else
      flash[:error] = 'Only moderators can moderate posts.'
      redirect_to '/dashboard'
    end
  end

  def _spam_queue
    if logged_in_as(%w(moderator admin))
      @tags_followed = TagSelection.where(following: true, user_id: current_user.id)
      @tag_queue = case params[:tag]
                   when 'everything'
                     TagSelection.where(following: true, user_id: current_user.id)
                   else
                     tids = Tag.where(name: params[:tag]).collect(&:tid)
                     TagSelection.where(following: true, tid: tids, user_id: current_user.id)
                   end
      nodes = []
      @tag_queue.each do |tag_queue_name|
        nodes += NodeTag.where(tid: tag_queue_name.tid).collect(&:nid)
      end
      @queue = Node.where(status: [0, 4]).or(Node.where('flag > ?', 0))
                    .where(nid: nodes, type: %w(note page))
                    .paginate(page: params[:page], per_page: 30)
                    .order('changed DESC')
                    .distinct
      render template: 'spam2/_spam'
    else
      flash[:error] = 'Only moderators can moderate posts.'
      redirect_to '/dashboard'
    end
  end

  def _spam_users
    if logged_in_as(%w(moderator admin))
      @users = User.paginate(page: params[:page], per_page: params[:pagination]).order('created_at DESC')
      @users = case params[:type]
                 when 'banned'
                   @users.where('rusers.status = 0')
                 when 'moderator'
                   @users.where('rusers.role = ?', params[:type])
                 when 'admin'
                   @users.where('rusers.role = ?', params[:type])
                 else
                   @users.where('rusers.status = 1')
                 end
      render template: 'spam2/_spam'
    else
      flash[:error] = 'Only moderators can moderate other users.'
      redirect_to '/dashboard'
    end
  end

  def _spam_revisions
    if logged_in_as(%w(admin moderator))
      @revisions = Revision.where(status: 0)
                           .paginate(page: params[:page], per_page: 30)
                           .order('timestamp DESC')
      render template: 'spam2/_spam'
    else
      flash[:error] = 'Only moderators and admins can moderate this.'
      redirect_to '/dashboard'
    end
  end

  def _spam_insights
    if logged_in_as(%w(admin moderator))
      @graph_spammed = Node.spam_graph_making(0)
      @graph_unmoderated = Node.spam_graph_making(4)
      @graph_flagged = Node.where('flag > ?', 0).spam_graph_making(1)
      @moderator_tag = Tag.tag_frequency(30)
      @popular_tags = Tag.tag_frequency(10)
      render template: 'spam2/_spam'
    else
      flash[:error] = 'Only moderators and admins can access this page.'
      redirect_to '/dashboard'
    end
  end

  def _spam_comments
    if logged_in_as(%w(moderator admin))
      @comments = Comment.paginate(page: params[:page], per_page: params[:pagination])
      @comments = case params[:type]
                  when 'unmoderated'
                    @comments.where(status: 4).order('timestamp DESC')
                  when 'published'
                    @comments.where(status: 1).order('timestamp DESC')
                  when 'spammed'
                    @comments.where(status: 0).order('timestamp DESC')
                  when 'flagged'
                    @comments.where('flag > ?', 0).order('flag DESC')
                  else
                    @comments.where(status: [0, 4])
                    .or(@comments.where('flag > ?', 0))
                    .order('timestamp DESC')
                  end
      render template: 'spam2/_spam'
    else
      flash[:error] = 'Only moderators can moderate comments.'
      redirect_to '/dashboard'
    end
  end

  def flag_node
    @node = Node.find params[:id]
    @node.flag_node
    flash[:notice] = 'Node flagged.'
    redirect_back fallback_location: root_path
  end

  def remove_flag_node
    if logged_in_as(%w(moderator admin))
      @node = Node.find params[:id]
      if @node.flag.zero?
        flash[:notice] = 'Node already unflagged.'
      else
        @node.unflag_node
      end
    else
      flash[:error] = 'Only admins and moderators can unflag nodes.'
      redirect_to '/dashboard'
    end
  end

  def flag_comment
    @comment = Comment.find params[:id]
    @comment.flag_comment
    flash[:notice] = 'Comment flagged.'
    redirect_back fallback_location: root_path
  end

  def remove_flag_comment
    if logged_in_as(%w(admin moderator))
      @comment = Comment.find params[:id]
      @comment.unflag_comment
    else
      flash[:error] = 'Only moderators can unflag comments.'
      redirect_to '/dashboard'
    end
  end
end
