class Spam2Controller < ApplicationController
  before_action :require_user, only: %i(_spam _spam_revisions _spam_comments)

  def _spam
    if logged_in_as(%w(moderator admin))
      @nodes = Node.order('changed DESC')
                   .paginate(page: params[:page], per_page: 100)
      @nodes = if params[:type] == 'wiki'
                 @nodes.where(type: 'page', status: 1)
               else
                 @nodes.where(status: [0, 4])
               end
      @spam_count = @nodes.where(status: 0).length
      @unmoderated_count = @nodes.where(status: 4).length
      @page_count = @nodes.where(type: 'page').length
      @note_count = @nodes.where(type: 'note').length
    else
      flash[:error] = 'Only moderators can moderate posts.'
      redirect_to '/dashboard'
    end
  end

  def _spam_revisions
    if logged_in_as(%w(admin moderator))
      @revisions = Revision.where(status: 0)
                           .paginate(page: params[:page], per_page: 100)
                           .order('timestamp DESC')
      render template: 'spam2/_spam'
    else
      flash[:error] = 'Only moderators and admins can moderate this.'
      redirect_to '/dashboard'
    end
  end

  def _spam_comments
    if logged_in_as(%w(moderator admin))
      @comments = Comment.where(status: 0)
                         .order('timestamp DESC')
                         .paginate(page: params[:page], per_page: 100)
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
end
