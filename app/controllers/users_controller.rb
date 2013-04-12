class UsersController < ApplicationController

  def new
    @user = User.new
    redirect_to "/wiki/registration"
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
    @user = current_user
    @user.attributes = params[:user]
    @user.save do |result|
      if result
        flash[:notice] = "Successfully updated profile."
        redirect_to root_url
      else
        render :action => 'edit'
      end
    end
  end

  def edit
    @user = User.find(params[:id])
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
