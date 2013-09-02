class AdminController < ApplicationController

  before_filter :require_user, :only => [:spam]

  def promote_admin
    if current_user && current_user.role == "admin"
      @user = User.find params[:id]
      @user.role = 'admin'
      @user.save({})
      flash[:notice] = "User '<a href='/profile/"+@user.username+"'>"+@user.username+"</a>' is now an admin."
    else
      flash[:error] = "Only admins can promote other users to admins."
    end
    redirect_to "/profile/"+@user.username
  end

  def promote_moderator
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      @user = User.find params[:id]
      @user.role = 'moderator'
      @user.save({})
      flash[:notice] = "User '<a href='/profile/"+@user.username+"'>"+@user.username+"</a>' is now a moderator."
    else
      flash[:error] = "Only moderators can promote other users."
    end
    redirect_to "/profile/"+@user.username
  end

  def demote_basic
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      @user = User.find params[:id]
      @user.role = 'basic'
      @user.save({})
      flash[:notice] = "User '<a href='/profile/"+@user.username+"'>"+@user.username+"</a>' is no longer a moderator."
    else
      flash[:error] = "Only moderators can demote other users."
    end
    redirect_to "/profile/"+@user.username
  end

  def spam
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      if params[:type] == "wiki"
        @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => "page", :status => 1}, :page => params[:page])
      else 
        @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:status => 0}, :page => params[:page])
      end
    else
      flash[:error] = "Only moderators can moderate posts."
      redirect_to "/dashboard"
    end
  end

  def mark_spam
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      @node = DrupalNode.find params[:id]
      @node.status = 0
      @node.save
      flash[:notice] = "Item marked as spam. You can undo this on the <a href='/spam'>spam moderation page</a>."
      redirect_to "/dashboard"
    else
      flash[:error] = "Only moderators can publish posts."
      redirect_to @node.path
    end
  end

  def publish
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      @node = DrupalNode.find params[:id]
      @node.status = 1
      @node.save
      flash[:notice] = "Item published."
      redirect_to @node.path
    else
      flash[:error] = "Only moderators can publish posts."
      redirect_to "/dashboard"
    end
  end

  def geocode
    if current_user && current_user.username == "warren"
      succeeded = 0
      failed = 0
      if params[:all]
        @users = DrupalUsers.locations
      elsif params[:name]
        @users = DrupalUsers.find_all_by_name params[:name]
      else
        @users = DrupalUsers.find(:all, :conditions => ["lat = 0.0 AND profile_values.fid = 2 AND profile_values.value != ''"], :include => :drupal_profile_values)
      end
      @users.each do |user|
        if user.geocode
          succeeded += 1
        else
          failed += 1
        end
      end 
      render :text => succeeded.to_s+' OK, '+failed.to_s+' failed'
    else
      prompt_login "Only admins can view that page."
    end
  end

  def ban
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      user = DrupalUsers.find params[:id]
      user.status = 0
      user.save({})
      #user.notes.each do |note|
      #  note.status = 0
      #  note.save
      #end
      flash[:notice] = "The user has been banned."
    else
      flash[:error] = "Only moderators can ban other users."
    end
    redirect_to "/profile/"+user.name
  end

  def unban
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      user = DrupalUsers.find params[:id]
      user.status = 1
      user.save({})
      flash[:notice] = "The user has been unbanned."
    else
      flash[:error] = "Only moderators can unban other users."
    end
    redirect_to "/profile/"+user.name
  end

  def users
    if current_user && (current_user.role == "moderator" || current_user.role == "admin")
      @users = DrupalUsers.find :all, :order => "uid DESC", :limit => 200
    else
      flash[:error] = "Only moderators can moderate other users."
      redirect_to "/dashboard"
    end
  end

  def batch
    if current_user && (current_user.role == "admin")
      nodes = 0
      users = []
      params[:ids].split(',').uniq.each do |nid|
        node = DrupalNode.find nid
        node.status = 0
        node.save
        nodes += 1
        user = node.author
        user.status = 0
        user.save({})
        users << user.id
      end
      flash[:notice] = nodes.to_s+" nodes spammed and "+users.length.to_s+" users banned."
      redirect_to "/spam/wiki"
    else
      flash[:error] = "Only admins can batch moderate."
      redirect_to "/dashboard"
    end
  end

end
