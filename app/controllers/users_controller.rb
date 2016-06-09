class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new]
  before_filter :require_user, :only => [:update]

  def new
    @spamaway = Spamaway.new
    @user = User.new
    @action = "create" # sets the form url
  end

  def create
    # craft a publiclaboratory OpenID URI around the PL username given:
    params[:user][:openid_identifier] = "https://old.publiclab.org/people/"+params[:user][:openid_identifier]+"/identity" if params[:user] && params[:user][:openid_identifier]
    @spamaway = Spamaway.new(params[:spamaway])
    @user = User.new(params[:user])
    if @spamaway.valid?
#    if params[:user]
      @user.save({}) do |result| # <<<<< THIS LINE WAS THE PROBLEM FOR "Undefined [] for True" error...
        if result
          if current_user.crypted_password.nil? # the user has not created a pwd in the new site
            flash[:warning] = "Your account has been migrated from the old PublicLaboratory.org website; please create a password for the new site."
            redirect_to "/profile/edit"
          else
            @user.drupal_user.set_bio(params[:drupal_user][:bio])
            @user.add_to_lists(['publiclaboratory'])
            flash[:notice] = "Registration successful. You've been added to the <b>publiclaboratory</b> mailing list."
            flash[:warning] = "<i class='icon icon-exclamation-sign'></i> If you registered in order to use <b>SpectralWorkbench.org</b> or <b>MapKnitter.org</b>, <a href='#{session[:openid_return_to]}'>click here to continue &raquo;</a>" if session[:openid_return_to]
            session[:openid_return_to] = nil 
            redirect_to "/dashboard"
          end
        else
          # didn't create a new user!
          @action = "create"
          render :action => 'new'
        end
      end
    else
      # register any user errors
      @user.valid?
      # pipe all spamaway errors into the user error display
      @spamaway.errors.full_messages.each do |message|
          @user.errors.add(:spam_detection, message)
      end
      # send all errors to the page so the user can try again
      @action = "create"
      render :action => 'new'
    end
  end

  def update
    if current_user
    @user = current_user
      @user.attributes = params[:user]
      @user.drupal_user.set_bio(params[:drupal_user][:bio])
      @user.save({}) do |result|
        if result
          if session[:openid_return_to] # for openid login, redirects back to openid auth process
            return_to = session[:openid_return_to]
            session[:openid_return_to] = nil
            redirect_to return_to
          else
            flash[:notice] = "Successfully updated profile. <a href='/dashboard'>Return to your dashboard &raquo;</a>"
            redirect_to "/profile/"+@user.username
          end
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
    @action = "update" # sets the form url
    if params[:id] # admin only
      @drupal_user = DrupalUsers.find_by_name(params[:id])
      @user = @drupal_user.user
    else
      @user = current_user
      @drupal_user = current_user.drupal_user
    end
    if current_user && current_user.uid == @user.uid #|| current_user.role == "admin"
      render :template => "users/edit.html.erb"
    else
      flash[:error] = "Only <b>"+@user.name+"</b> can edit their profile."
      redirect_to "/profile/"+@user.name
    end
  end

  def list
    # allow admins to view recent users
    if params[:id]
      @users = DrupalUsers.joins('INNER JOIN rusers ON rusers.username = users.name')
                          .order("updated_at DESC")
                          .where('rusers.role = ?', params[:id])
                          .page(params[:page])
    else
      # recently active
      @users = DrupalUsers.select('*, MAX(node.changed) AS last_updated')
                          .joins(:drupal_node)
                          .group('users.uid')
                          .where('users.status = 1 AND node.status = 1')
                          .order("last_updated DESC")
                          .page(params[:page])
    end
    @users = @users.where('users.status = 1') unless current_user && (current_user.role == "admin" || current_user.role == "moderator")
  end

  def profile
    @user = DrupalUsers.find_by_name(params[:id])
    @title = @user.name
    @notes = DrupalNode.page(params[:page])
                       .order("nid DESC")
                       .where(type: 'note', status: 1, uid: @user.uid)
    wikis = DrupalNodeRevision.order("nid DESC")
                              .where('node.type' => 'page', 'node.status' => 1, uid: @user.uid)
                              .joins(:drupal_node)
                              .limit(20)
    @wikis = wikis.collect(&:parent).uniq
    if @user.status == 0 && !(current_user && (current_user.role == "admin" || current_user.role == "moderator"))
      flash[:error] = "That user has been banned."
      redirect_to "/"
    end 
  end

  def likes
    @user = DrupalUsers.find_by_name(params[:id])
    @title = "Liked by "+@user.name
    @notes = @user.liked_notes.includes([:drupal_tag, :drupal_comments])
                              .paginate(page: params[:page], per_page: 20)
    @wikis = @user.liked_pages
    @tagnames = []
    @unpaginated = false
  end

  def rss
    if params[:author]
      @author = DrupalUsers.find_by_name params[:author]
      if @author
        @notes = DrupalNode.order("nid DESC")
                           .where(type: 'note', status: 1, uid: @author.uid)
                           .limit(20)
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
        response.headers["Access-Control-Allow-Origin"] = "*"
      } 
    end
  end

  def reset
    if params[:key] && params[:key] != nil
      @user = User.find_by_reset_key(params[:key])
      if @user
        if params[:user] && params[:user][:password]
          if @user.username.downcase == params[:user][:username].downcase
            @user.attributes = params[:user]
            @user.reset_key = nil
            if @user.save({})
            flash[:notice] = "Your password was successfully changed."
            redirect_to "/dashboard"
            else
              flash[:error] = "Password reset failed. Please <a href='/wiki/issues'>contact the web team</a> if you are having trouble."
              redirect_to "/"
            end
          else
            flash[:error] = "Password change failed; key does not correspond to username."
          end
        else
          # Just display page prompting username & pwd
        end
      else
        flash[:error] = "Password reset failed. Please <a href='/wiki/issues'>contact the web team</a> if you are having trouble. (Error: no user with that key)"
        redirect_to "/"
      end
      
    elsif params[:email]
      user = User.find_by_email params[:email]
      if user
        key = user.generate_reset_key
        user.save({})
        # send key to user email
        PasswordResetMailer.reset_notify(user,key) unless user.nil? # respond the same to both successes and failures; security
      end
      flash[:notice] = "You should receive an email with instructions on how to reset your password. If you do not, please double check that you are using the email you registered with."
      redirect_to "/login"
    end
  end

  def comments
    @comments = DrupalComment.limit(20)
                             .order("timestamp DESC")
                             .where(status: 0, uid: params[:id])
    render :partial => "home/comments"
  end

  def photo
    @user = DrupalUsers.find_by_uid(params[:uid]).user
    if current_user.uid == @user.uid || current_user.role == "admin"
      @user.photo = params[:photo]
      if @user.save!
        if request.xhr?
          render :json => { :url => @user.photo_path } 
        else
          flash[:notice] = "Image saved."
          redirect_to @node.path
        end
      else
        flash[:error] = "The image could not be saved."
        redirect_to "/images/new"
      end
    else
      flash[:error] = "The image could not be saved."
      redirect_to "/images/new"
    end
  end

  def info
  end

end
