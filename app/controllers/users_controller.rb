class UsersController < ApplicationController
  before_action :require_no_user, only: [:new]
  before_action :require_user, only: %i(edit update save_settings settings)
   before_action :set_user, only: %i(info followed following followers)

  def new
    @user = User.new
    @action = "create" # sets the form url
  end

  def create
    @user = User.new(user_params)
    @user.status = 1
    using_recaptcha = !params[:spamaway] && Rails.env == "production"
    recaptcha = verify_recaptcha(model: @user) if using_recaptcha
    @spamaway = Spamaway.new(spamaway_params) unless using_recaptcha

    if ((@spamaway&.valid?) || recaptcha) && @user.save # pass spamaway validation FIRST then try saving the user; https://github.com/publiclab/plots2/issues/8463
      if current_user.crypted_password.nil? # the user has not created a pwd in the new site
        flash[:warning] = I18n.t('users_controller.account_migrated_create_new_password')
        redirect_to "/profile/edit"
      else
        begin
          WelcomeMailer.notify_newcomer(@user).deliver_now
        rescue StandardError
          flash[:warning] = "We tried and failed to send you a welcome email, but your account was created anyhow. Sorry!"
        end
        flash[:notice] = I18n.t('users_controller.registration_successful')
        if params[:return_to] && params[:return_to].split('/')[0..3] == ["", "subscribe", "multiple", "tag"]
          flash[:notice] += "You are now following '#{params[:return_to].split('/')[4]}'."
          subscribe_multiple_tag(params[:return_to].split('/')[4])
        elsif params[:return_to] && params[:return_to] != "/signup" && params[:return_to] != "/login"
          flash[:notice] += " " + I18n.t('users_controller.continue_where_you_left_off', url1: params[:return_to].to_s)
        end
        flash[:notice] = flash[:notice].html_safe
        flash[:warning] = I18n.t('users_controller.spectralworkbench_or_mapknitter', url1: "#{session[:openid_return_to]}'").html_safe if session[:openid_return_to]
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
    @password_verification = user_verification_params
    @user = current_user
    @user = User.find_by(username: params[:id]) if params[:id] && logged_in_as(['admin'])
    if @user.valid_password?(user_verification_params["current_password"]) || user_verification_params["ui_update"].nil? || (user_verification_params["current_password"].blank? && user_verification_params["password"].blank? && user_verification_params["password_confirmation"].blank?)
      # correct password or if any other field needs to be updated
      @user.attributes = user_params
      if @user.save
        if session[:openid_return_to] # for openid login, redirects back to openid auth process
          return_to = session[:openid_return_to]
          session[:openid_return_to] = nil
          redirect_to return_to
        else
          flash[:notice] = I18n.t('users_controller.successful_updated_profile') + "<a href='/profile'>" + I18n.t('users_controller.return_profile') + " &raquo;</a>"
          return redirect_to "/profile/" + @user.username + "/edit"
        end
      else
        render template: 'users/edit'
      end
    else
      # incorrect password
      flash[:error] = "Current Password is incorrect!"
      return redirect_to "/profile/" + @user.username + "/edit"
    end
  end

  def edit
    @action = "update" # sets the form url
    @user = if params[:id] # admin only
              User.find_by(username: params[:id])
            else
              current_user
            end
    if current_user && current_user.uid == @user.uid || logged_in_as(['admin'])
      render template: "users/edit"
    else
      flash[:error] = I18n.t('users_controller.only_user_edit_profile', user: @user.name).html_safe
      redirect_to "/profile/" + @user.name
    end
  end

  def list
    sort_param = params[:sort]
    @tagname_param = params[:tagname]

    order_string = if params[:id]
                     'updated_at DESC'
                   else
                     'last_updated DESC'
                   end

    if sort_param == 'username'
      order_string = 'username ASC'
    elsif sort_param == 'last_activity'
      order_string = 'last_updated DESC'
    elsif sort_param == 'joined'
      order_string = 'created_at DESC'
    end

    @map_lat = nil
    @map_lon = nil
    @map_zoom = nil
    if current_user&.has_power_tag("lat") && current_user&.has_power_tag("lon")
      @map_lat = current_user.get_value_of_power_tag("lat").to_f
      @map_lon = current_user.get_value_of_power_tag("lon").to_f
      if current_user&.has_power_tag("zoom")
        @map_zoom = current_user.get_value_of_power_tag("zoom").to_f
      end
    end
    # allow admins to view recent users
    @users = if params[:id]
               User.order(order_string)
                             .where('rusers.role = ?', params[:id])
                             .where('rusers.status = 1')
                             .page(params[:page])

             elsif @tagname_param
               User.where(id: UserTag.where(value: @tagname_param).collect(&:uid))
                             .page(params[:page])

             else
               # recently active
               User.select('*, rusers.status, MAX(node_revisions.timestamp) AS last_updated')
                            .joins(:revisions)
                            .where("node_revisions.status = 1")
                            .group('rusers.id')
                            .order(order_string)
                            .page(params[:page])
             end

    @users = @users.where('rusers.status = 1') unless current_user&.can_moderate?
  end

  def profile
    if current_user && params[:id].nil?
      redirect_to "/profile/#{current_user.username}"
    elsif !current_user && params[:id].nil?
      redirect_to "/"
    else
      @profile_user = User.find_by(username: params[:id])
      if !@profile_user
        flash[:error] = I18n.t('users_controller.no_user_found_name', username: params[:id])
        redirect_to "/"
      else
        @title = @profile_user.name
        wikis = Revision.order("nid DESC")
                        .where('node.type' => 'page', 'node.status' => 1, uid: @profile_user.uid)
                        .joins(:node)
                        .limit(20)
        @wikis = wikis.collect(&:parent).uniq
        # User's social links
        @content_approved = !(Node.where(status: 1, uid: @profile_user.id).empty?) or !(Comment.where(status: 1, uid: @profile_user.id).empty?)
        @github = @profile_user.social_link("github")
        @twitter = @profile_user.social_link("twitter")
        @facebook = @profile_user.social_link("facebook")
        @instagram = @profile_user.social_link("instagram")
        @count_activities_posted = Tag.tagged_nodes_by_author("activity:*", @profile_user).size
        @count_activities_attempted = Tag.tagged_nodes_by_author("replication:*", @profile_user).size
        @map_lat = nil
        @map_lon = nil
        @map_zoom = nil
        if @profile_user.has_power_tag("lat") && @profile_user.has_power_tag("lon")
          @map_lat = @profile_user.get_value_of_power_tag("lat").to_f
          @map_lon = @profile_user.get_value_of_power_tag("lon").to_f
          @map_zoom = @profile_user.get_value_of_power_tag("zoom").to_i if @profile_user.has_power_tag("zoom")
          @map_blurred = @profile_user.has_tag('blurred:true')
        end

        if @profile_user.status == 0
          if current_user&.can_moderate?
            flash.now[:error] = I18n.t('users_controller.user_has_been_banned')
          else
            flash[:error] = I18n.t('users_controller.user_has_been_banned')
            redirect_to "/"
          end
        elsif @profile_user.status == 5
          flash.now[:warning] = I18n.t('users_controller.user_has_been_moderated')
        end
      end
    end
  end

  def likes
    @user = User.find_by(username: params[:id])
    @title = "Liked by " + @user.name
    @pagy, @notes = pagy(@user.liked_notes
                  .includes(%i(tag comments)), items: 24)
    @wikis = @user.liked_pages
    @tagnames = []
    @unpaginated = false
  end

  def rss
    if params[:author]
      @author = User.where(username: params[:author], status: 1).first
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
    if params[:key] && !params[:key].nil?
      @user = User.find_by(reset_key: params[:key])
      if @user
        if params[:user] && params[:user][:password]
          if @user.username.casecmp(params[:user][:username].downcase).zero?
            @user.password = params[:user][:password]
            @user.password_confirmation = params[:user][:password]
            @user.reset_key = nil
            if @user.changed? && @user.save
              flash[:notice] = I18n.t('users_controller.password_change_success')
              @user.password_checker = 0
              @user.save
              redirect_to "/dashboard"
            else
              flash[:error] = I18n.t('users_controller.password_reset_failed').html_safe
              redirect_to "/"
            end
          else
            flash[:error] = I18n.t('users_controller.password_change_failed')
          end
        end
      else
        flash[:error] = I18n.t('users_controller.password_reset_failed_no_user').html_safe
        redirect_to "/"
      end

    elsif params[:email]
      user = User.find_by(email: params[:email])
      if user
        key = user.generate_reset_key
        user.save
        # send key to user email
        PasswordResetMailer.reset_notify(user, key).deliver_now unless user.nil? # respond the same to both successes and failures; security
      end
      flash[:notice] = I18n.t('users_controller.password_reset_email')
      redirect_to "/login"
    end
  end

  def comments
    comments = Comment.limit(20)
                             .order("timestamp DESC")
                             .where(uid: User.where(username: params[:id], status: 1).first)
                             .paginate(page: params[:page], per_page: 24)

    @normal_comments = comments.where('comments.status = 1')
    if logged_in_as(['admin', 'moderator'])
      @moderated_comments = comments.where('comments.status = 4')
    end
    render template: 'comments/index'
  end

  def comments_by_tagname
    comments = Comment.limit(20)
                             .order("timestamp DESC")
                             .where(uid: User.where(username: params[:id], status: 1).first)
                             .where(nid: Node.where(status: 1)
                              .includes(:node_tag, :tag)
                              .references(:term_data)
                              .where('term_data.name = ?', params[:tagname]))
                             .paginate(page: params[:page], per_page: 24)

    @normal_comments = comments.where('comments.status = 1')
    if logged_in_as(['admin', 'moderator'])
      @moderated_comments = comments.where('comments.status = 4')
    end
    render template: 'comments/index'
  end

  def photo
    @user = User.find_by(id: params[:uid])
    if current_user.uid == @user.uid || current_user.admin?
      @user.photo = params[:photo]
      if @user.save!
        if request.xhr?
          render json: { url: @user.photo_path }
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

  def info; end

  # content this person follows
  def followed
    render json: @user.content_followed_in_past_period(time_period)
  end

  def following
    @title = "Following"
    @pagy, @users = pagy(@user.following_users, items: 10)
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @users = @user.followers.paginate(page: params[:page], per_page: 10)
    render 'show_follow'
  end

  def test_digest_email
    DigestMailJob.perform_async(0)
    redirect_to "/"
  end

  def save_settings
    user_settings = [
      'notify-comment-direct:false',
      'notify-likes-direct:false',
      'notify-comment-indirect:false',
      'no-moderation-emails'
    ]

    user_settings.each do |setting|
      if params[setting] && params[setting] == "on"
        UserTag.remove_if_exists(current_user.uid, setting)
      else
        UserTag.create_if_absent(current_user.uid, setting)
      end
    end

    digest_settings = [
      'digest:weekly',
      'digest:daily',
      'digest:weekly:spam',
      'digest:daily:spam'
    ]
    digest_settings.each do |setting|
      if params[setting] == "on"
        UserTag.create_if_absent(current_user.uid, setting)
      else
        UserTag.remove_if_exists(current_user.uid, setting)
      end
    end

    notification_settings = [
      'notifications:all',
      'notifications:mentioned',
      'notifications:like'
    ]

    notification_settings.each do |setting|
      if params[setting] == "on"
        UserTag.create_if_absent(current_user.uid, setting)
      else
        UserTag.remove_if_exists(current_user.uid, setting)
      end
    end

    flash[:notice] = "Settings updated successfully!"
    render js: "window.location.reload()"
  end

  def shortlink
    @user = User.find_by_username(params[:username])
    if @user
      redirect_to @user.path
    else
      raise ActiveRecord::RecordNotFound.new(message: "Couldn't find user with username #{params[:id]}")
    end
  end

  def verify_email
    decrypted_user_id = User.validate_token(params[:token])
    action_msg = "Email verification failed"
    if decrypted_user_id != 0
      user_obj = User.find(decrypted_user_id)
      if user_obj.is_verified
        action_msg = "Email already verified"
      else
        user_obj.update_column(:is_verified, true)
        action_msg = "Successfully verified email"
      end
    end
    redirect_to "/login", flash: { notice: action_msg }
  end

  private

  def subscribe_multiple_tag(tag_list)
    if !tag_list || tag_list == ''
      flash[:notice] = "Please enter tags for subscription in the url."
    else
      if tag_list.is_a? String
        tag_list = tag_list.split(',')
      end
      tag_list.each do |t|
        next unless t.size.positive?
        tag = Tag.find_by(name: t)
        unless tag.present?
          tag = Tag.new(
            vid: 3, # vocabulary id
            name: t,
            description: "",
            weight: 0
          )
          begin
            tag.save!
            rescue ActiveRecord::RecordInvalid
            flash[:error] = tag.errors.full_messages
            redirect_to "/subscriptions" + "?_=" + Time.now.to_i.to_s
            return false
          end
        end
        # test for uniqueness
        unless TagSelection.where(following: true, user_id: current_user.uid, tid: tag.tid).size.positive?
          # Successfully we have added subscription
          if Tag.find_by(tid: tag.tid)
            # Create the entry if it isn't already created.
            # assume tag, for now:
            subscription = TagSelection.where(user_id: current_user.uid,
                                              tid: tag.tid).first_or_create
            subscription.following = true
            # Check if the value changed.
            if subscription.following_changed?
              subscription.save!
            end
          else
            flash.now[:error] = "Sorry! There was an error in tag subscriptions. Please try it again."
          end
        end
      end
    end
  end

  def set_user
    @user = User.find_by(username: params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :openid_identifier, :key, :photo, :photo_file_name, :bio, :status)
  end

  def user_verification_params
    params.require(:user).permit(:ui_update, :current_password, :password, :password_confirmation)
  end

  def spamaway_params
    params.require(:spamaway).permit(:follow_instructions, :statement1, :statement2, :statement3, :statement4)
  end
end
