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
                 when 'spammed'
                   @nodes.where(status: 0).order('changed DESC')
                 when 'created'
                   @nodes.where(status: [0, 4]).order('created DESC')
                 else
                   @nodes.where(status: [0, 4]).order('changed DESC')
                 end
      @node_unmoderated_count = Node.where(status: 4).size
      @node_flag_count = Node.where('flag > ?', 0).size
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

  def _spam_users
    if logged_in_as(%w(moderator admin))
      @users = User.paginate(page: params[:page], per_page: params[:pagination])
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
      @user_active_count = User.where('rusers.status = 1').size
      @user_ban_count = User.where('rusers.status = 0').size
      render template: 'spam2/_spam'
    else
      flash[:error] = 'Only moderators can moderate other users.'
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
      @comments = Comment.paginate(page: params[:page], per_page: params[:pagination])
      @comments = case params[:type]
                  when 'unmoderated'
                    @comments.where(status: 4).order('timestamp DESC')
                  when 'spammed'
                    @comments.where(status: 0).order('timestamp DESC')
                  when 'flagged'
                    @comments.where('flag > ?', 0).order('flag DESC')
                  else
                    @comments.where(status: [0, 4])
                    .or(@comments.where('flag > ?', 0))
                    .order('timestamp DESC')
                  end
      @comment_unmoderated_count = Comment.where(status: 4).size
      @comment_flag_count = Comment.where('flag > ?', 0).size
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
      flash[:notice] = node_spamed.to_s + ' nodes spammed and ' + user_spamed.size.to_s + ' users banned.'
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
      flash[:notice] = node_published.to_s + ' nodes published and ' + user_published.size.to_s + ' users unbanned.'
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
      params[:ids].split(',').uniq.each do |nid|
        node = Node.find nid
        user = node.author
        user_ban << user.id
        user.ban
      end
      flash[:notice] = user_ban.size.to_s + ' users banned.'
      redirect_back fallback_location: root_path
    else
      flash[:error] = 'Only admins and moderators can ban users.'
      redirect_to '/dashboard'
    end
  end

  def batch_unban
    unbanned_users = []
    if logged_in_as(%w(moderator admin))
      params[:ids].split(',').uniq.each do |node_id|
        node = Node.find node_id
        user_unban = node.author
        unbanned_users << user_unban.id
        user_unban.unban
      end
      flash[:notice] = unbanned_users.size.to_s + ' users unbanned.'
      redirect_back fallback_location: root_path
    else
      flash[:error] = 'Only admins and moderators can unban users.'
      redirect_to '/dashboard'
    end
  end

  def batch_ban_user
    users = []
    if logged_in_as(%w(admin moderator))
      params[:ids].split(',').uniq.each do |user_id|
        user_ban = User.find user_id
        users << user_ban.id
        user_ban.ban
      end
      flash[:notice] = users.size.to_s + ' users banned.'
      redirect_back fallback_location: root_path
    else
      flash[:error] = 'Only moderators can moderate users.'
      redirect_to '/dashboard'
    end
  end

  def batch_unban_user
    if logged_in_as(%w(moderator admin))
      params[:ids].split(',').uniq.each do |id|
        unban_user = User.find id
        unban_user.unban
      end
      flash[:notice] = 'Success! users unbanned.'
      redirect_back fallback_location: root_path
    else
      flash[:error] = 'Only admins and moderators can moderate users.'
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
