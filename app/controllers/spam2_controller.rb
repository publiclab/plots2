class Spam2Controller < ApplicationController
  before_action :require_user, only: %i(_spam _spam_revisions _spam_comments)

  def _spam
    if logged_in_as(%w(moderator admin))
      @nodes = Node.order('changed DESC')

      @nodes =  if params[:type] == 'wiki'
                  @nodes.where(type: 'page', status: 1)
                elsif params[:type] == 'unmoderated'
                  @nodes.where(status: 4)
                elsif params[:type] == 'spammed'
                  @nodes.where(status: 0)
                elsif params[:type] == 'page'
                  @nodes.where(type: 'page', status: [0, 4])
                elsif params[:type] == 'note'
                  @nodes.where(type: 'note', status: [0, 4])
                elsif params[:type] == 'all'
                  @nodes.where(status: [0, 4])
                else
                  @nodes.where(status: [0, 4])
               end

      @spam_count = @nodes.where(status: 0).length
      @unmoderated_count = @nodes.where(status: 4).length
      @page_count = @nodes.where(type: 'page').length
      @note_count = @nodes.where(type: 'note').length

      @nodes =  if params[:pagination]?
                  @nodes.paginate(page: params[:page], per_page: params[:pagination])
                else
                  @nodes.paginate(page: params[:page], per_page: 30)
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
      @flags = if params[:type] == 'unmoderated'
                    @flags.where(status: 4)
               elsif params[:type] == 'spammed'
                    @flags.where(status: 0)
               elsif params[:type] == 'page'
                    @flags.where(type: 'page')
               elsif params[:type] == 'note'
                    @flags.where(type: 'note')
               elsif params[:type] == 'all'
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
      @comments = if params[:type] == 'unmoderated'
                      @comments.where(status: 4)
                  elsif params[:type] == 'spammed'
                      @comments.where(status: 0)
                  elsif params[:type] == 'flagged'
                      @comments.where('flag > ?', 0)
                  elsif params[:type] == 'all'
                      @comments.where(status: [0, 4])
                               .or(@comments.where('flag > ?', 0))
                  end

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
      flash[:error] = 'Only admins and moderators can unban nodes.'
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
      if @comment.flag.zero?
        flash[:notice] = 'Comment is already unflagged.'
      else
        @comment.unflag_comment
      end
    else
      flash[:error] = 'Only admins and moderators can unflag comments.'
      redirect_to '/dashboard'
    end
  end
end
