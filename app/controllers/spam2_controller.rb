class Spam2Controller < ApplicationController
  before_action :require_user, only: %i(_spam _spam_revisions _spam_comments)

  def _spam
    if logged_in_as(%w(moderator admin))
      @nodes = Node.order('changed DESC').paginate(page: params[:page], per_page: params[:pagination])
      @nodes = case params[:type]
               when 'wiki'
                 @nodes.where(type: 'page', status: 1)
               when 'unmoderated'
                 @nodes.where(status: 4)
               when 'spammed'
                 @nodes.where(status: 0)
               else
                 @nodes.where(status: [0, 4])
               end
      @node_unmoderated_count = Node.where(status: 4).length
      @node_flag_count = Node.where('flag > ?', 0).length
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

  def _spam_revisions
    if logged_in_as(%w(admin moderator))
      @revisions = Revision.where(status: 0)
                           .paginate(page: params[:page], per_page: 50)
                           .order('timestamp DESC')
      render template: 'spam2/_spam'
    else
      flash[:error] = 'Only moderators and admins can moderate this.'
      redirect_to '/dashboard'
    end
  end

  def _spam_comments
    if logged_in_as(%w(moderator admin))
      @comments = Comment.order('flag DESC')
                  .paginate(page: params[:page], per_page: params[:pagination])
      @comments = case params[:type]
                  when 'unmoderated'
                    @comments.where(status: 4)
                  when 'spammed'
                    @comments.where(status: 0)
                  when 'flagged'
                    @comments.where('flag > ?', 0)
                  else
                    @comments.where(status: [0, 4])
                    .or(@comments.where('flag > ?', 0))
                  end
      @comment_unmoderated_count = Comment.where(status: 4).length
      @comment_flag_count = Comment.where('flag > ?', 0).length
      render template: 'spam2/_spam'
    else
      flash[:error] = 'Only moderators can moderate comments.'
      redirect_to '/dashboard'
    end
  end

  def batch_spam
    if logged_in_as(%w(moderator admin))
      user_spamed = []
      node_spamed = 0
      params[:ids].split(',').uniq.each do |nid|
        node = Node.find nid
        node_spamed += 1
        node.spam
        user = node.author
        user_spamed << user.id
        user.ban
      end
      flash[:notice] = node_spamed.to_s + ' nodes spammed and ' + user_spamed.length.to_s + ' users banned.'
      redirect_to '/spam2'
    else
      flash[:error] = 'Only admins and moderators can mark a batch spam.'
      redirect_to '/dashboard'
    end
  end

  def batch_publish
    if logged_in_as(%w(moderator admin))
      node_published = 0
      user_published = []
      params[:ids].split(',').uniq.each do |nid|
        node = Node.find nid
        node_published += 1
        node.publish
        user = node.author
        user.unban
        user_published << user.id
      end
      flash[:notice] = node_published.to_s + ' nodes published and ' + user_published.length.to_s + ' users unbanned.'
      redirect_to '/spam2'
    else
      flash[:error] = 'Only admins and moderators can batch publish.'
      redirect_to '/dashboard'
    end
  end

  def batch_delete
    if logged_in_as(%w(moderator admin))
      node_delete = 0
      params[:ids].split(',').uniq.each do |nid|
        node = Node.find nid
        node_delete += 1
        node.delete
      end
      flash[:notice] = node_delete.to_s + ' nodes deleted'
      redirect_back fallback_location: root_path
    else
      flash[:error] = 'Only admins and moderators can batch delete.'
      redirect_to '/dashboard'
    end
  end

  def batch_ban
    if logged_in_as(%w(admin moderator))
      user_ban = []
      node_ban = 0
      params[:ids].split(',').uniq.each do |nid|
        node = Node.find nid
        user = node.author
        user.ban
        user_ban << user.id
        node_ban += 1
      end
      flash[:notice] = user_ban.length.to_s + ' users banned.'
      redirect_back fallback_location: root_path
    else
      flash[:error] = 'Only admins and moderators can ban users.'
      redirect_to '/dashboard'
    end
  end

  def batch_unban
    if logged_in_as(%w(moderator admin))
      users_unban = []
      params[:ids].split(',').uniq.each do |nid|
        node = Node.find nid
        user = node.author
        user.unban
        users_unban << user.id
      end
      flash[:notice] = users_unban.length.to_s + ' users unbanned.'
      redirect_back fallback_location: root_path
    else
      flash[:error] = 'Only admins and moderators can unban users.'
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
