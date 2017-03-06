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
    using_recaptcha = !params[:spamaway] && Rails.env == "production"
    @spamaway = Spamaway.new(params[:spamaway]) unless using_recaptcha
    @user = User.new(params[:user])
    if ((@spamaway && @spamaway.valid?) || (using_recaptcha && recaptcha = verify_recaptcha(model: @user))) && @user.save({})
      if current_user.crypted_password.nil? # the user has not created a pwd in the new site
        flash[:warning] = I18n.t('users_controller.account_migrated_create_new_password')
        redirect_to "/profile/edit"
      else
        @user.drupal_user.set_bio(params[:drupal_user][:bio])
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
      @drupal_user = DrupalUsers.find_by_name(params[:id])
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
    @profile_user = User.find_by_username(params[:id])
    @title = @user.name
    @notes = DrupalNode.research_notes
                       .page(params[:page])
                       .order("nid DESC")
                       .where(status: 1, uid: @user.uid)
    @questions = @user.user.questions
                           .order('node.nid DESC')
                           .paginate(:page => params[:page], :per_page => 30)
    questions = DrupalNode.questions
                          .where(status: 1)
                          .order('node.nid DESC')
    @answered_questions = questions.select{|q| q.answers.collect(&:author).include?(@user)}
    wikis = DrupalNodeRevision.order("nid DESC")
                              .where('node.type' => 'page', 'node.status' => 1, uid: @user.uid)
                              .joins(:drupal_node)
                              .limit(20)
    @wikis = wikis.collect(&:parent).uniq
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

  def likes
    @user = DrupalUsers.find_by_name(params[:id])
    @title = "Liked by "+@user.name
    @notes = @user.liked_notes.includes([:tag, :comments])
                              .paginate(page: params[:page], per_page: 20)
    @wikis = @user.liked_pages
    @tagnames = []
    @unpaginated = false
  end

  def rss
    if params[:author]
      @author = DrupalUsers.find_by_name_and_status( params[:author], 1 )
      if @author
        @notes = DrupalNode.order("nid DESC")
                           .where(type: 'note', status: 1, uid: @author.uid)
                           .limit(20)
      else
        flash[:error] = I18n.t('users_controller.no_user_found')
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
      user = User.find_by_email params[:email]
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
                             .paginate(page: params[:page], per_page: 30)
    render partial: 'comments/comments'
  end

  def photo
    @user = DrupalUsers.find_by_uid(params[:uid]).user
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
    @user = DrupalUsers.find_by_name(params[:id])
    @location_tag = @user.location_tag
  end

  def privacy
  # maintains location privacy functionality
    status = params[:location_privacy]
    @output = {
      errors: [],
      status: false
    }

    user = DrupalUsers.find_by_name(params[:id])
    if current_user.update_attribute(:location_privacy, status)
      @output[:status] = true
    else
      @output[:errors] << flash[:error]
    end

    if user.location_tag
      @lat, @long =  user.location_tag.lat, user.location_tag.lon
    end

    respond_to do |format|
      format.json {
        render json: {
          status: @output[:status],
          model: current_user,
          lat: @lat,
          long: @long
        }.to_json
      }

      format.html {
        if @output[:status]
          flash[:notice] = I18n.t('users_controller.preference_saved')
        else
          flash[:error] = I18n.t('users_controller.something_went_wrong')
        end
        redirect_to info_path(params[:id])
      }
    end

  end

  def following
    @title = "Following"
    @user  = User.find_by_username(params[:id])
    @users = @user.following_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find_by_username(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  def map
#    @title = "Maps"
#    valid_tags = ["skill", "role", "gear", "tool"]
#    tag = params[:tag].downcase if params[:tag]
#
#    value = params[:value]
#    @country = params[:country]
#
#    if !tag.blank?
#      if !valid_tags.include? tag
#        flash[:error] = "#{tag} doesn't exitst"
#      end
#      @location_tags = Hash.new
#      LocationTag.all.each do |location_tag|
#        if !value.empty?
#          @user_tags = location_tag.drupal_users.user.user_tags.select { |utag| utag if utag.value == "#{tag}:#{value}" }
#        else
#          @user_tags = location_tag.drupal_users.user.user_tags.select { |utag| utag if utag.value =~ /\A#{tag}:[A-Za-z0-9]*\z/ }
#        end
#
#        if !@user_tags.empty?
#          if @location_tags[[location_tag.lat, location_tag.lon]]
#            @user_tags.each do |user_tag|
#              @location_tags[[location_tag.lat, location_tag.lon]] << user_tag
#            end
#          else
#            @location_tags[[location_tag.lat, location_tag.lon]] = []
#            @user_tags.each do |user_tag|
#              @location_tags[[location_tag.lat, location_tag.lon]] << user_tag
#            end
#          end
#        end
#      end
#    elsif !@country.blank?
#      @users = DrupalUsers.all.select {|user| user.location_tag if user.location_tag }
#                .select {|user| user.location_tag if user.location_tag.country && user.location_tag.country == @country }
#    else
#      @users = DrupalUsers.all.select {|user| user.location_tag if !user.location_tag.nil? } if !@users
#    end
  end

end
