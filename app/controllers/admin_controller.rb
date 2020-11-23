class AdminController < ApplicationController
  before_action :require_user, only: %i(spam spam_revisions mark_comment_spam publish_comment spam_comments)

  # intended to provide integration tests for assets
  def assets; end

  def promote_admin
    @user = User.find params[:id]
    unless @user.nil?
      if logged_in_as(['admin'])
        @user.role = 'admin'
        @user.save
        flash[:notice] = "User '<a href='/profile/" + @user.username + "'>" + @user.username + "</a>' is now an admin."
      else
        flash[:error] = 'Only admins can promote other users to admins.'
      end
    end
    redirect_to '/profile/' + @user.username + '?_=' + Time.now.to_i.to_s
  end

  def promote_moderator
    @user = User.find params[:id]
    unless @user.nil?
      if logged_in_as(['admin', 'moderator'])
        @user.role = 'moderator'
        @user.save
        flash[:notice] = "User '<a href='/profile/" + @user.username + "'>" + @user.username + "</a>' is now a moderator."
      else
        flash[:error] = 'Only moderators can promote other users.'
      end
    end
    redirect_to '/profile/' + @user.username + '?_=' + Time.now.to_i.to_s
  end

  def demote_basic
    @user = User.find params[:id]
    unless @user.nil?
      if logged_in_as(['admin', 'moderator'])
        @user.role = 'basic'
        @user.save
        flash[:notice] = "User '<a href='/profile/" + @user.username + "'>" + @user.username + "</a>' is no longer a moderator."
      else
        flash[:error] = 'Only admins and moderators can demote other users.'
      end
    end
    redirect_to '/profile/' + @user.username + '?_=' + Time.now.to_i.to_s
  end

  def reset_user_password
    if logged_in_as(['admin'])
      user = User.find(params[:id])
      if user
        key = user.generate_reset_key
        user.save
        # send key to user email
        PasswordResetMailer.reset_notify(user, key).deliver_later unless user.nil? # respond the same to both successes and failures; security
      end
      flash[:notice] = "#{user.name} should receive an email with instructions on how to reset their password. If they do not, please double check that they are using the email they registered with."
      redirect_to URI.parse("/profile/" + user.name).path
    end
  end

  def useremail 
   if logged_in_as(['admin', 'moderator']) 
     if params[:address] 
       # address was submitted. find the username(s) and return. 
       @address = params[:address] 
       if params[:include_banned]
         @users = User.where(email: params[:address]) 
           .where('created_at > (?)', DateTime.new(2015)) # since 2015, whether banned or not
       else
         @users = User.where(email: params[:address]) 
           .where(status: [1, 4]) 
       end
     end 
   else 
     # unauthorized. instead of return ugly 403, just send somewhere else 
     redirect_to '/dashboard' 
   end
  end


  def spam
    if logged_in_as(['admin', 'moderator'])
      @nodes = Node.paginate(page: params[:page])
                   .order('nid DESC')
      @nodes = if params[:type] == 'wiki'
                 @nodes.where(type: 'page', status: 1)
               else
                 @nodes.where(status: [0, 4]) # spam OR as-yet-unmoderated posts
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
      render template: 'admin/spam'
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
      render template: 'admin/spam'
    else
      flash[:error] = 'Only moderators can moderate comments.'
      redirect_to '/dashboard'
    end
  end

  def mark_spam
    @node = Node.find params[:id]
    if logged_in_as(['admin', 'moderator'])
      if @node.status == 1 || @node.status == 4
        @node.spam
        @node.author.ban
        @node.unflag_node
        # No longer notifying other moderators as of https://github.com/publiclab/plots2/issues/6246
        # AdminMailer.notify_moderators_of_spam(@node, current_user).deliver_later
        flash[:notice] = "Item marked as spam and author banned. You can undo this on the <a href='/spam'>spam moderation page</a>."
        redirect_to '/dashboard' + '?_=' + Time.now.to_i.to_s
      else
        flash[:notice] = "Item already marked as spam and author banned. You can undo this on the <a href='/spam'>spam moderation page</a>."
        redirect_to '/dashboard'
      end
    else
      flash[:error] = 'Only moderators can moderate posts.'
      if @node.has_power_tag('question')
        redirect_to @node.path(:question)
      else
        redirect_to @node.path
      end
    end
  end

  def mark_comment_spam
    @comment = Comment.find params[:id]
    if logged_in_as(['admin', 'moderator'])
      if @comment.status == 1 || @comment.status == 4
        @comment.spam
        user = @comment.author
        user.ban
        @comment.unflag_comment
        # No longer notifying other moderators as of https://github.com/publiclab/plots2/issues/6246
        # AdminMailer.notify_moderators_of_comment_spam(@comment, current_user).deliver_later
        flash[:notice] = "Comment has been marked as spam and comment author has been banned. You can undo this on the <a href='/spam/comments'>spam moderation page</a>."
      else
        flash[:notice] = "Comment already marked as spam."
      end
    else
      flash[:error] = 'Only moderators can moderate comments.'
    end
    redirect_to @comment.node.path + '?_=' + Time.now.to_i.to_s
  end

  def publish_comment
    if logged_in_as(['admin', 'moderator'])
      @comment = Comment.find params[:id]
      if @comment.status == 1
        flash[:notice] = 'Comment already published.'
      else
        first_timer_comment = (@comment.status == 4)
        @comment.publish
        if @comment.author.banned?
          @comment.author.unban
        end
        @comment.unflag_comment
        if first_timer_comment
          AdminMailer.notify_author_of_comment_approval(@comment, current_user).deliver_later
          # No longer notifying other moderators as of https://github.com/publiclab/plots2/issues/6246
          # AdminMailer.notify_moderators_of_comment_approval(@comment, current_user).deliver_later
        else
          flash[:notice] = 'Comment published.'
        end
      end
      @node = @comment.node
      redirect_to @node.path + '?_=' + Time.now.to_i.to_s
    else
      flash[:error] = 'Only moderators can publish comments.'
      redirect_to '/dashboard'
    end
  end

  def publish
    if logged_in_as(['admin', 'moderator'])
      @node = Node.find params[:id]
      if @node.status == 1
        flash[:notice] = 'Item already published.'
      else
        first_timer_post = (@node.status == 4)
        @node.publish
        @node.author.unban
        if first_timer_post
          AdminMailer.notify_author_of_approval(@node, current_user).deliver_later
          # No longer notifying other moderators as of https://github.com/publiclab/plots2/issues/6246
          # AdminMailer.notify_moderators_of_approval(@node, current_user).deliver_later
          SubscriptionMailer.notify_node_creation(@node).deliver_now
          flash[:notice] = if @node.has_power_tag('question')
                             "Question approved and published after #{time_ago_in_words(@node.created_at)} in moderation. Now reach out to the new community member; thank them, just say hello, or help them revise/format their post in the comments."
                           else
                             "Post approved and published after #{time_ago_in_words(@node.created_at)} in moderation. Now reach out to the new community member; thank them, just say hello, or help them revise/format their post in the comments."
                           end
        else
          flash[:notice] = 'Item published.'
        end
      end
      if @node.has_power_tag('question')
        redirect_to @node.path(:question)
      else
        redirect_to @node.path
      end
    else
      flash[:error] = 'Only moderators can publish posts.'
      redirect_to '/dashboard'
    end
  end

  def mark_spam_revision
    @revision = Revision.find_by(vid: params[:vid])
    @node = Node.find_by(nid: @revision.nid)

    if @node.revisions.size <= 1
      flash[:warning] = "You can't delete the last remaining revision of a page; try deleting the wiki page itself (if you're an admin) or contacting moderators@publiclab.org for assistance."
      redirect_to @node.path
      return
    end

    if logged_in_as(['admin', 'moderator'])
      if @revision.status == 1
        @revision.spam
        @revision.author.ban
        flash[:notice] = "Item marked as spam and author banned. You can undo this on the <a href='/spam/revisions'>spam moderation page</a>."
        redirect_to '/wiki/revisions/' + @revision.node.slug_from_path + '?_=' + Time.now.to_i.to_s
      else
        flash[:notice] = "Item already marked as spam and author banned. You can undo this on the <a href='/spam/revisions'>spam moderation page</a>."
        redirect_to '/dashboard'
      end
    else
      flash[:error] = 'Only moderators can moderate posts.'
      if @node.has_power_tag('question')
        redirect_to @node.path(:question)
      else
        redirect_to @node.path
      end
    end
  end

  def publish_revision
    if logged_in_as(['admin', 'moderator'])
      @revision = Revision.find params[:vid]
      @revision.publish
      @revision.author.unban
      flash[:notice] = 'Item published.'
      if @revision.parent.has_power_tag('question')
        redirect_to @revision.parent.path(:question)
      else
        redirect_to @revision.parent.path
      end
    else
      flash[:error] = 'Only moderators can publish posts.'
      redirect_to '/dashboard'
    end
  end

  def moderate
    user = User.find params[:id]
    if logged_in_as(['admin', 'moderator'])
      user.moderate
    else
      flash[:error] = 'Only moderators can moderate other users.'
    end
    redirect_to '/profile/' + user.name + '?_=' + Time.now.to_i.to_s
  end

  def unmoderate
    user = User.find params[:id]
    if logged_in_as(['admin', 'moderator'])
      user.unmoderate
      flash[:notice] = 'The user has been unmoderated.'
    else
      flash[:error] = 'Only moderators can unmoderate other users.'
    end
    redirect_to '/profile/' + user.name + '?_=' + Time.now.to_i.to_s
  end

  def ban
    user = User.find params[:id]
    if logged_in_as(['admin', 'moderator'])
      user.ban
    else
      flash[:error] = 'Only moderators can ban other users.'
    end
    redirect_to '/profile/' + user.name + '?_=' + Time.now.to_i.to_s
  end

  def unban
    user = User.find params[:id]
    if logged_in_as(['admin', 'moderator'])
      user.unban
      flash[:notice] = 'The user has been unbanned.'
    else
      flash[:error] = 'Only moderators can unban other users.'
    end
    redirect_to '/profile/' + user.name + '?_=' + Time.now.to_i.to_s
  end

  def users
    if logged_in_as(['admin', 'moderator'])
      @users = User.order('uid DESC').limit(200)
    else
      flash[:error] = 'Only moderators can moderate other users.'
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
      flash[:notice] = nodes.to_s + ' nodes spammed and ' + users.size.to_s + ' users banned.'
      redirect_to '/spam/wiki'
    else
      flash[:error] = 'Only admins can batch moderate.'
      redirect_to '/dashboard'
    end
  end

  def migrate
    if logged_in_as(['admin'])
      du = User.find params[:id]
      if du.user
        flash[:error] = 'The user has already been migrated.'
      else
        if du.migrate
          flash[:notice] = 'The user was migrated! Enthusiasm!'
        else
          flash[:error] = 'The user could not be migrated.'
        end
      end
    else
      flash[:error] = 'Only admins can migrate users.'
    end
    redirect_to '/profile/' + du.name
  end

  def queue
    if logged_in_as(['admin', 'moderator'])
      @notes = Node.where(status: 4)
                   .paginate(page: params[:page])
      flash[:warning] = "These are notes requiring moderation. <a href='/wiki/moderation'>Community moderators</a> may approve or reject them."
      render template: 'notes/index'
    else
      flash[:error] = 'Only moderators and admins can see the moderation queue.'
      redirect_to '/dashboard'
    end
  end

  def smtp_test
    require 'socket'

    s = TCPSocket.new ActionMailer::Base.smtp_settings[:address], ActionMailer::Base.smtp_settings[:port]

    while line = s.gets # Read lines from socket
      if line.include? '220'
        s.print "MAIL FROM: <example@publiclab.org>\n"
      end
      if line.include? '250 OK'
        s.print "RCPT TO: <example@publiclab.org>\n"
      end
      if line.include? '250 Accepted'
        render plain: "Email gateway OK"
        s.close_write
      elsif line.include? '550'
        render plain: "Email gateway NOT OK"
        render status: 500
        s.close_write
      end
    end

    s.close
  end

  def test_digest_email_spam
    DigestSpamJob.perform_async(0)
    redirect_to "/spam"
  end
end
