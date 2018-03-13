class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new]
  before_filter :require_user, :only => [:update]

  def new
    @spamaway = Spamaway.new
    @user = User.new
    @action = "create" # sets the form url
  end

  def create
    @user = User.new(params[:user])
    @user.status = 1
    using_recaptcha = !params[:spamaway] && Rails.env == "production"
    recaptcha = verify_recaptcha(model: @user) if using_recaptcha
    @spamaway = Spamaway.new(params[:spamaway]) unless using_recaptcha
    if ((@spamaway&.valid?) || recaptcha) && @user.save({})
      if current_user.crypted_password.nil? # the user has not created a pwd in the new site
        flash[:warning] = I18n.t('users_controller.account_migrated_create_new_password')
        redirect_to "/profile/edit"
      else
        @user.add_to_lists(['publiclaboratory'])
        flash[:notice] = I18n.t('users_controller.registration_successful').html_safe
        flash[:warning] = I18n.t('users_controller.spectralworkbench_or_mapknitter', :url1 => "'#{session[:openid_return_to]}'").html_safe if session[:openid_return_to]
        session[:openid_return_to] = nil
        redirect_to "/dashboard"
      end
    else
      # pipe all spamaway errors into the user error display
      if @spamaway
        @spamaway.errors.full_messages.each do |message|
          @user.errors.add(:spam_detection, message)
        end
      elsif using_recaptcha && recaptcha == false
        flash.now[:warning] = "If you're having trouble creating an account, try <a href='/signup?spamaway=true'>the alternative signup form</a>, or <a href='mailto:staff@publiclab.org'>ask staff for help</a>"
      end
      # send all errors to the page so the user can try again
      @action = "create"
      render action: 'new'
    end
  end

  def update
    if current_user
    @user = current_user
      @user.attributes = params[:user]
      @user.save({}) do |result|
        if result
          if session[:openid_return_to] # for openid login, redirects back to openid auth process
            return_to = session[:openid_return_to]
            session[:openid_return_to] = nil
            redirect_to return_to
          else
            flash[:notice] = I18n.t('users_controller.successful_updated_profile')+"<a href='/dashboard'>"+I18n.t('users_controller.return_dashboard')+" &raquo;</a>"
            redirect_to "/profile/"+@user.username
          end
        else
          render :template => 'users/edit'
        end
      end
    else
      flash[:error] = I18n.t('users_controller.only_user_edit_profile', :user => @user.name).html_safe
      redirect_to "/profile/"+@user.name
    end
  end

  def edit
    @action = "update" # sets the form url
    if params[:id] # admin only
      @drupal_user = DrupalUser.find_by(name: params[:id])
      @user = @drupal_user.user
    else
      @user = current_user
      @drupal_user = current_user.drupal_user
    end
    if current_user && current_user.uid == @user.uid #|| current_user.role == "admin"
      render :template => "users/edit"
    else
      flash[:error] = I18n.t('users_controller.only_user_edit_profile', :user => @user.name).html_safe
      redirect_to "/profile/"+@user.name
    end
  end

  def list
    sort_param = params[:sort]

    if params[:id]
      order_string = 'updated_at DESC'
    else
      order_string = 'last_updated DESC'
    end

    if sort_param == 'username'
      order_string = 'name ASC'
    elsif sort_param == 'last_activity'
      order_string = 'last_updated DESC'
    elsif sort_param == 'joined'
      order_string = 'created DESC'
    end

    # allow admins to view recent users
    if params[:id]
      @users = DrupalUser.joins('INNER JOIN rusers ON rusers.username = users.name')
                          .order(order_string)
                          .where('rusers.role = ?', params[:id])
                          .where('rusers.status = 1')
                          .page(params[:page])
    else
      # recently active
      @users = DrupalUser.select('*, MAX(node.changed) AS last_updated')
                          .joins(:node)
                          .group('users.uid')
                          .where('node.status = 1')
                          .order(order_string)
                          .page(params[:page])
    end
    @users = @users.where('users.status = 1') unless current_user && (current_user.role == "admin" || current_user.role == "moderator")
  end

  def profile
    if current_user && params[:id].nil?
      redirect_to "/profile/#{current_user.username}"
    else
      @user = DrupalUser.find_by(name: params[:id])
      @profile_user = User.find_by(username: params[:id])
      @title = @user.name
      @notes = Node.research_notes
                   .paginate(page: params[:page], per_page: 24)
                   .order("nid DESC")
                   .where(status: 1, uid: @user.uid)
      @coauthored = @profile_user.coauthored_notes
                                 .paginate(page: params[:page], per_page: 24)
                                 .order('node_revisions.timestamp DESC')
      @questions = @user.user.questions
                             .order('node.nid DESC')
                             .paginate(:page => params[:page], :per_page => 24)
      @likes = (@user.liked_notes.includes([:tag, :comments])+@user.liked_pages)
                     .paginate(page: params[:page], per_page: 24)
      questions = Node.questions
                            .where(status: 1)
                            .order('node.nid DESC')
      ans_ques = questions.select{|q| q.answers.collect(&:author).include?(@user)}
      @answered_questions = ans_ques.paginate(page: params[:page], per_page: 24)
      wikis = Revision.order("nid DESC")
                      .where('node.type' => 'page', 'node.status' => 1, uid: @user.uid)
                      .joins(:node)
                      .limit(20)
      @wikis = wikis.collect(&:parent).uniq

      @comment_count = Comment.where(status: 0, uid: @user.uid).count

      # User's social links
      @github = @profile_user.social_link("github")
      @twitter = @profile_user.social_link("twitter")
      @facebook = @profile_user.social_link("facebook")
      @instagram = @profile_user.social_link("instagram")
      @count_activities_posted = Tag.tagged_nodes_by_author("activity:*", @user).count
      @count_activities_attempted = Tag.tagged_nodes_by_author("replication:*", @user).count
      @map_lat = nil
      @map_lon = nil
      if @profile_user.has_power_tag("lat") && @profile_user.has_power_tag("lon")
        @map_lat = @profile_user.get_value_of_power_tag("lat").to_f
        @map_lon = @profile_user.get_value_of_power_tag("lon").to_f
        @map_blurred = @profile_user.has_tag("blurred:true")
      end

      if @user.status == 0
        if current_user && (current_user.role == "admin" || current_user.role == "moderator")
          flash.now[:error] = I18n.t('users_controller.user_has_been_banned')
        else
          flash[:error] = I18n.t('users_controller.user_has_been_banned')
          redirect_to "/"
        end
      elsif @user.status == 5
        flash.now[:warning] = I18n.t('users_controller.user_has_been_moderated')
      end
    end
  end

  def likes
    @user = DrupalUser.find_by(name: params[:id])
    @title = "Liked by "+@user.name
    @notes = @user.liked_notes
                  .includes([:tag, :comments])
                  .paginate(page: params[:page], per_page: 24)
    @wikis = @user.liked_pages
    @tagnames = []
    @unpaginated = false
  end

  def rss
    if params[:author]
      @author = DrupalUser.where(name: params[:author], status: 1).first
      if @author
        @notes = Node.order("nid DESC")
                           .where(type: 'note', status: 1, uid: @author.uid)
                           .limit(20)
        respond_to do |format|
          format.rss do
            render layout: false
            response.headers['Content-Type'] = 'application/xml; charset=utf-8'
            response.headers['Access-Control-Allow-Origin'] = '*'
          end
        end
      else
        flash[:error] = I18n.t('users_controller.no_user_found')
        redirect_to "/"
      end
    end
  end

  def reset
    if params[:key] && params[:key] != nil
      @user = User.find_by(reset_key: params[:key])
      if @user
        if params[:user] && params[:user][:password]
          if @user.username.downcase == params[:user][:username].downcase
            @user.password = params[:user][:password]
            @user.password_confirmation = params[:user][:password]
            @user.reset_key = nil
            if @user.changed? && @user.save({})
              flash[:notice] = I18n.t('users_controller.password_change_success')
              redirect_to "/dashboard"
            else
              flash[:error] = I18n.t('users_controller.password_reset_failed').html_safe
              redirect_to "/"
            end
	  else
            flash[:error] = I18n.t('users_controller.password_change_failed')
          end
        else
          # Just display page prompting username & pwd
        end
      else
        flash[:error] = I18n.t('users_controller.password_reset_failed_no_user').html_safe
        redirect_to "/"
      end

    elsif params[:email]
      user = User.find_by(email: params[:email])
      if user
        key = user.generate_reset_key
        user.save({})
        # send key to user email
        PasswordResetMailer.reset_notify(user, key) unless user.nil? # respond the same to both successes and failures; security
      end
      flash[:notice] = I18n.t('users_controller.password_reset_email')
      redirect_to "/login"
    end
  end

  def comments
    @comments = Comment.limit(20)
                             .order("timestamp DESC")
                             .where(status: 0, uid: params[:id])
                             .paginate(page: params[:page])
    render partial: 'comments/comments'
  end

  def photo
    @user = DrupalUser.find_by(uid: params[:uid]).user
    if current_user.uid == @user.uid || current_user.role == "admin"
      @user.photo = params[:photo]
      if @user.save!
        if request.xhr?
          render :json => { :url => @user.photo_path }
        else
          flash[:notice] = I18n.t('users_controller.image_saved')
          redirect_to @node.path
        end
      else
        flash[:error] = I18n.t('users_controller.image_not_saved')
        redirect_to "/images/new"
      end
    else
      flash[:error] = I18n.t('users_controller.image_not_saved')
      redirect_to "/images/new"
    end
  end

  def info
    @user = User.find_by(username: params[:id])
  end

  # content this person follows
  def followed
    user = User.find_by(username: params[:id])
    render json: user.content_followed_in_past_period(time_period)
  end

  def following
    @title = "Following"
    @user  = User.find_by(username: params[:id])
    @users = @user.following_users.paginate(page: params[:page], per_page: 24)
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find_by(username: params[:id])
    @users = @user.followers.paginate(page: params[:page], per_page: 24)
    render 'show_follow'
  end

end
