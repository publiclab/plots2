class UsersController < ApplicationController
  before_filter :require_user, :only => [:update]

  def new
    @user = User.new
    redirect_to "/wiki/registration" unless params[:test] == "true"
  end

  def create
    # craft a publiclaboratory OpenID URI around the PL username given:
    params[:user][:openid_identifier] = "http://publiclaboratory.org/people/"+params[:user][:openid_identifier]+"/identity" if params[:user]
    @user = User.new(params[:user])
#    if params[:user]
      @user.save({}) do |result| # <<<<< THIS LINE WAS THE PROBLEM FOR "Undefined [] for True" error...
        if result
          flash[:notice] = "Registration successful."
          redirect_to "/dashboard"
        else
          render :action => 'new'
        end
      end
#    else
#      render :action => 'new'
#    end
  end

  def update
    if current_user
    @user = current_user
      #if current_user && current_user.uid == @user.uid #|| current_user.role == "admin"
      @user.attributes = params[:user]
      @user.drupal_user.set_bio(params[:drupal_user][:bio])
      @user.save({}) do |result|
        if result
          flash[:notice] = "Successfully updated profile."
          redirect_to "/profile/"+@user.username
        else
          render :template => 'users/edit'
        end
      end
    else
      flash[:error] = "Only <b>"+@user.name+"</b> can edit their profile."
      redirect_to "/profile/"+@user.name
    end
  end

  def edit
    @drupal_user = DrupalUsers.find_by_name(params[:id])
    @user = @drupal_user.user
    if current_user && current_user.uid == @user.uid #|| current_user.role == "admin"
      render :template => "users/edit.html.erb"
    else
      flash[:error] = "Only <b>"+@user.name+"</b> can edit their profile."
      redirect_to "/profile/"+@user.name
    end
  end

  def list
    if true #current_user && current_user.role == "admin"
      @users = User.find :all, :limit => 100 # improve
    end
  end

  def profile
    @user = DrupalUsers.find_by_name(params[:id])
    @title = @user.name
  end

  def likes
    @user = DrupalUsers.find_by_name(params[:id])
    @title = "Liked by "+@user.name
    @notes = @user.liked_notes
    @wikis = @user.liked_pages
    @tagnames = []
    @unpaginated = true
  end

  def rss
    if params[:author]
      @author = DrupalUsers.find_by_name params[:author]
      if @author
        @notes = DrupalNode.find(:all,:order => "nid DESC", :conditions => {:type => 'note', :status => 1, :uid => @author.uid},:limit => 20)
      else
        flash[:error] = "No user by that name found"
        redirect_to "/"
      end
    else
    end
    respond_to do |format|
      format.rss {
        render :layout => false
        response.headers["Content-Type"] = "application/xml; charset=utf-8"
      } 
    end
  end

end
