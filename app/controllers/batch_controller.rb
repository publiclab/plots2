class BatchController < ApplicationController
  before_action :require_user

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
      params[:ids].split(',').uniq.each do |nid|
        node = Node.find nid
        user = node.author
        user_ban << user.id
        user.ban
      end
      flash[:notice] = user_ban.length.to_s + ' users banned.'
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
      flash[:notice] = unbanned_users.length.to_s + ' users unbanned.'
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
      flash[:notice] = users.length.to_s + ' users banned.'
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

  def batch_comment
    if logged_in_as(%w(moderator admin))
      comment_total = 0
      params[:ids].split(',').uniq.each do |cid|
        comment = Comment.find cid
        comment_total += 1
        case params[:type]
        when 'publish'
          comment.publish
        when 'spam'
          comment.spam
          user.ban
        when 'delete'
          comment.delete
        else
          flash[:notice] = 'Invalid Url'
        end
      end
      flash[:notice] = comment_total.to_s + ' comment moderated'
      redirect_back fallback_location: root_path
    else
      flash[:error] = 'Only admins and moderators can moderate comments.'
      redirect_to '/dashboard'
    end
  end
end
