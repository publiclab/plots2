class Spam2Controller < ApplicationController
  before_action :require_user, only: %i(spam spam_revisions mark_comment_spam publish_comment spam_comments)

  def spam
    if logged_in_as(['admin', 'moderator'])
      @nodes = Node.paginate(page: params[:page])
                   .order('nid DESC')
      @nodes = if params[:type] == 'wiki'
                @nodes.where(type: 'page', status: 1)
               else
                @nodes.where(status: [0, 4])
               end
    else
      flash[:error] = 'Only moderators can moderate posts.'
      redirect_to '/dashboard'
    end
  end

  def spam_revisions
    if logged_in_as(['admin', 'moderator'])
      @revisions = Revision.paginate(page: params[:page])
                           .order('timestamp DESC')
                           .where(status: 0)
      render template: 'spam2/spam'
    else
      flash[:error] = 'Only moderators can moderate revisions.'
      redirect_to '/dashboard'
    end
  end

  def spam_comments
    if current_user &. can_moderate?
      @comments = Comment.paginate(page: params[:page])
                       .order('timestamp DESC')
                       .where(status: 0)
      render template: 'spam2/spam'
    else
      flash[:error] = 'Only moderators can moderate comments.'
      redirect_to '/dashboard'
    end
  end

  def batch
    if logged_in_as(['admin', 'moderator'])
      nodes = 0
      users = []
      params[:ids].split(',').uniq.each do |nid|
        node = Node.find nid
        node.spam
        nodes += 1
        user = node.author
        user.ban
        users << user.id
      end
      flash[:notice] = nodes.to_s + ' nodes spammed and ' + users.length.to_s + ' users banned.'
      redirect_to '/spam2/wiki'
    else
      flash[:error] = 'Only admins can batch moderate.'
      redirect_to '/dashboard'
    end
  end

  def batch_publish
    if logged_in_as(['admin', 'moderator'])
      users = []
      nodes = 0
      params[:ids].split(',').uniq.each do |nid|
        node = Node.find nid
        node.publish
        user = node.author
        user.unban
        users << user.id
        nodes += 1
      end
      flash[:notice] = nodes.to_s + ' nodes published and ' + users.length.to_s + ' users unbanned.'
      redirect_to '/spam2'
    else
      flash[:error] = 'Only admins can batch moderate.'
      redirect_to '/dashboard'
    end
  end

  def batch_delete
    if logged_in_as(['admin', 'moderator'])
      nodes = 0
      params[:ids].split(',').uniq.each do |nid|
        node = Node.find nid
        node.delete
        nodes += 1
      end
      flash[:notice] = nodes.to_s + ' nodes deleted '
      redirect_to '/spam2/'
    else
      flash[:error] = 'Only admins can batch moderate.'
      redirect_to '/dashboard'
    end
  end

  def batch_ban
    if logged_in_as(['admin', 'moderator'])
      users = []
      nodes = 0
      params[:ids].split(',').uniq.each do |nid|
        node = Node.find nid
        user = node.author
        user.ban
        users << user.id
        nodes += 1
      end
      flash[:notice] = users.length.to_s + ' users banned.'
      redirect_to '/spam2'
    else
      flash[:error] = 'Only admins can batch moderate.'
      redirect_to '/dashboard'
    end
  end
end
