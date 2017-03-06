class AdminController < ApplicationController

  before_filter :require_user, :only => [:spam, :spam_revisions]

  def promote_admin
    @user = User.find params[:id]
    if !@user.nil?
      if current_user && current_user.role == "admin"
        @user.role = 'admin'
        @user.save({})
        flash[:notice] = "User '<a href='/profile/"+@user.username+"'>"+@user.username+"</a>' is now an admin."
      else
        flash[:error] = "Only admins can promote other users to admins."
      end
    end
    redirect_to "/profile/" + @user.username + "?_=" + Time.now.to_i.to_s
  end

  def promote_moderator
    @user = User.find params[:id]
    if !@user.nil?
      if current_user && (current_user.role == "moderator" || current_user.role == "admin")
        @user.role = 'moderator'
        @user.save({})
        flash[:notice] = "User '<a href='/profile/"+@user.username+"'>"+@user.username+"</a>' is now a moderator."
      else
        flash[:error] = "Only moderators can promote other users."
      end
    end
    redirect_to "/profile/" + @user.username + "?_=" + Time.now.to_i.to_s
  end

  def demote_basic
    @user = User.find params[:id]
    if !@user.nil?
      if current_user && (current_user.role == "moderator" || current_user.role == "admin")
        @user.role = 'basic'
        @user.save({})
        flash[:notice] = "User '<a href='/profile/"+@user.username+"'>"+@user.username+"</a>' is no longer a moderator."
      else
        flash[:error] = "Only admins and moderators can demote other users."
      end
    end
    redirect_to "/profile/" + @user.username + "?_=" + Time.now.to_i.to_s
  end

  def useremail
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      if params[:address]
        # address was submitted. find the username(s) and return.
        @address = params[:address]
        @users = User.find_all_by_email(params[:address])
      end
    else
      # unauthorized. instead of return ugly 403, just send somewhere else
      redirect_to '/dashboard'
    end
  end

  def spam
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      @nodes = Node.paginate(page: params[:page])
                         .order("nid DESC")
      if params[:type] == "wiki"
        @nodes = @nodes.where(type: "page", status: 1)
      else
        @nodes = @nodes.where(status: 0)
      end
    else
      flash[:error] = "Only moderators can moderate posts."
      redirect_to "/dashboard"
    end
  end

  def spam_revisions
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      @revisions = DrupalNodeRevision.paginate(page: params[:page])
                                     .order("timestamp DESC")
                                     .where(status: 0)
      render template: 'admin/spam'
    else
      flash[:error] = "Only moderators can moderate revisions."
      redirect_to "/dashboard"
    end
  end

  def mark_spam
    @node = Node.find params[:id]
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      if @node.status == 1 || @node.status == 4
        @node.spam
        @node.author.ban
        AdminMailer.notify_moderators_of_spam(@node, current_user)
        flash[:notice] = "Item marked as spam and author banned. You can undo this on the <a href='/spam'>spam moderation page</a>."
        redirect_to "/dashboard"
      else
        flash[:notice] = "Item already marked as spam and author banned. You can undo this on the <a href='/spam'>spam moderation page</a>."
        redirect_to "/dashboard"
      end
    else
      flash[:error] = "Only moderators can moderate posts."
      if @node.has_power_tag('question')
        redirect_to @node.path(:question)
      else
        redirect_to @node.path
      end
    end
  end

  def publish
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      @node = Node.find params[:id]
      if @node.status == 1
        flash[:notice] = "Item already published."
      else
        first_timer_post = (@node.status == 4)
        @node.publish
        @node.author.unban
        if first_timer_post
          AdminMailer.notify_author_of_approval(@node, current_user)
          AdminMailer.notify_moderators_of_approval(@node, current_user)
          SubscriptionMailer.notify_node_creation(@node)
          if @node.has_power_tag('question')
            flash[:notice] = "Question approved and published after #{time_ago_in_words(@node.created_at)} in moderation. Now reach out to the new community member; thank them, just say hello, or help them revise/format their post in the comments."
          else
            flash[:notice] = "Post approved and published after #{time_ago_in_words(@node.created_at)} in moderation. Now reach out to the new community member; thank them, just say hello, or help them revise/format their post in the comments."
          end
        else
          flash[:notice] = "Item published."
        end
      end
      if @node.has_power_tag('question')
        redirect_to @node.path(:question)
      else
        redirect_to @node.path
      end
    else
      flash[:error] = "Only moderators can publish posts."
      redirect_to "/dashboard"
    end
  end

  def mark_spam_revision
    @revision = DrupalNodeRevision.find_by_vid params[:vid]
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      if @revision.status == 1
        @revision.spam
        @revision.author.ban
        flash[:notice] = "Item marked as spam and author banned. You can undo this on the <a href='/spam/revisions'>spam moderation page</a>."
        redirect_to "/wiki/revisions/" + @revision.drupal_node.slug_from_path + '?_=' + Time.now.to_i.to_s
      else
        flash[:notice] = "Item already marked as spam and author banned. You can undo this on the <a href='/spam/revisions'>spam moderation page</a>."
        redirect_to "/dashboard"
      end
    else
      flash[:error] = "Only moderators can moderate posts."
      if @node.has_power_tag('question')
        redirect_to @node.path(:question)
      else
        redirect_to @node.path
      end
    end
  end

  def publish_revision
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      @revision = DrupalNodeRevision.find params[:vid]
      @revision.publish
      @revision.author.unban
      flash[:notice] = "Item published."
      if @revision.parent.has_power_tag('question')
        redirect_to @revision.parent.path(:question)
      else
        redirect_to @revision.parent.path
      end
    else
      flash[:error] = "Only moderators can publish posts."
      redirect_to "/dashboard"
    end
  end

  def moderate
    user = DrupalUsers.find params[:id]
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      user.moderate
      flash[:notice] = "The user has been moderated."
    else
      flash[:error] = "Only moderators can moderate other users."
    end
    redirect_to "/profile/" + user.name + "?_=" + Time.now.to_i.to_s
  end

  def unmoderate
    user = DrupalUsers.find params[:id]
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      user.unmoderate
      flash[:notice] = "The user has been unmoderated."
    else
      flash[:error] = "Only moderators can unmoderate other users."
    end
    redirect_to "/profile/" + user.name + "?_=" + Time.now.to_i.to_s
  end

  def ban
    user = DrupalUsers.find params[:id]
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      user.ban
      flash[:notice] = "The user has been banned."
    else
      flash[:error] = "Only moderators can ban other users."
    end
    redirect_to "/profile/" + user.name + "?_=" + Time.now.to_i.to_s
  end

  def unban
    user = DrupalUsers.find params[:id]
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      user.unban
      flash[:notice] = "The user has been unbanned."
    else
      flash[:error] = "Only moderators can unban other users."
    end
    redirect_to "/profile/" + user.name + "?_=" + Time.now.to_i.to_s
  end

  def users
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      @users = DrupalUsers.order("uid DESC").limit(200)
    else
      flash[:error] = "Only moderators can moderate other users."
      redirect_to "/dashboard"
    end
  end

  def batch
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
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
      flash[:notice] = nodes.to_s+" nodes spammed and "+users.length.to_s+" users banned."
      redirect_to "/spam/wiki"
    else
      flash[:error] = "Only admins can batch moderate."
      redirect_to "/dashboard"
    end
  end

  def migrate
    if current_user && current_user.role == "admin"
      du = DrupalUsers.find params[:id]
      if du.user
        flash[:error] = "The user has already been migrated."
      else
        if du.migrate
          flash[:notice] = "The user was migrated! Enthusiasm!"
        else
          flash[:error] = "The user could not be migrated."
        end
      end
    else
      flash[:error] = "Only admins can migrate users."
    end
    redirect_to "/profile/"+du.name
  end

  def queue
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      @notes = Node.where(status: 4)
                         .paginate(page: params[:page])
      flash[:warning] = "These are notes requiring moderation. <a href='/wiki/moderation'>Community moderators</a> may approve or reject them."
      render template: 'notes/index'
    else
      flash[:error] = "Only moderators and admins can see the moderation queue."
      redirect_to "/dashboard"
    end
  end

end
