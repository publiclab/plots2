class SubscriptionController < ApplicationController
  respond_to :html, :xml, :json
  before_action :require_user, only: %i(create delete index digest)

  def index
    @title = "Subscriptions"
    render template: "home/subscriptions"
  end

  # return a count of subscriptions for a given tag
  def tag_count
    render json: TagSelection.where(tid: params[:tid], following: true)
  end

  # for the current user, return whether is presently liked or not
  def followed
    # may be trouble: there can be multiple tags with the same name, no? We can eliminate that possibility in a migration if so.
    result = TagSelection.find_by_user_id_and_tid(current_user.uid, params[:id]) if params[:type] == "tag"
    result = if result.nil?
               false
             else
               result.following
             end
    render json: result
  end

  # for the current user, register as liking the given tag
  def add
    if current_user && params[:type] == "tag"

      tag = Tag.find_by(name: params[:name])

      unless tag.present?
        tag = Tag.new(
          vid: 3,
          name: params[:name],
          description: "",
          weight: 0
        )

        begin
          tag.save!
        rescue ActiveRecord::RecordInvalid
          return false
        end
      end

      case tag_selection_more_than_zero?(params[:tid])
      when true
        respond_to do |format|
          format.html do
            flash[:error] = "You are already subscribed to '#{params[:name]}'"

            redirect_to "/subscriptions" + "?_=" + Time.now.to_i.to_s
          end

          format.json do
            message = "You already follow this user!"

            render json: { status: :precondition_failed, error: message }
          end
        end
      else

        if set_following(true, params[:type], tag.tid)
          if request.xhr?
            message = "Started following #{params[:name]}!"
            status = "200"
            render json: { status: status, message: message, id: tag.tid, tagname: params[:name], url: "/tags" + "?_=" + Time.now.to_i.to_s } if current_user
          else
            flash[:notice] = "You are now following '#{params[:name]}'."
            redirect_to "/subscriptions" + "?_=" + Time.now.to_i.to_s
          end
        end
      end

    else
      flash[:warning] = "You must be logged in to subscribe for email updates; please <a class='requireLogin'>log in</a> or <a href='/signup'>create an account</a>."
      redirect_to "/tag/" + params[:name]
    end
  end

  # for the current user, remove the like from the given tag
  def delete
    # assume tag, for now
    if params[:type] == "tag"
      id = Tag.find_by(name: params[:name]).tid
    end
    if id.nil?
      flash[:error] = "You are not subscribed to '#{params[:name]}'"
      redirect_to "/subscriptions" + "?_=" + Time.now.to_i.to_s
    else
      if !set_following(false, params[:type], id) # should return false if result is that following == false
        respond_with do |format|
          format.html do
            if request.xhr?
              render json: true
            else
              flash[:notice] = "You have stopped following '#{params[:name]}'."
              redirect_to "/subscriptions" + "?_=" + Time.now.to_i.to_s
            end
          end
        end
      else
        flash[:error] = "Something went wrong!" # silly
        redirect_to "/subscriptions" + "?_=" + Time.now.to_i.to_s
      end
    end
  end

  def digest
    @wikis = current_user.content_followed_in_period(1.week.ago, Time.now)
      .paginate(page: params[:page], per_page: 100)

    @paginated = true
    render template: "subscriptions/digest"
  end

  def multiple_add
    return_to = params[:return_to] || "/subscriptions?_=" + Time.now.to_i.to_s
    if params[:tagnames].blank?
      flash[:notice] = "Please enter tags for subscription in the url."
      redirect_to return_to
    else
      tag_list = if params[:tagnames].is_a? String
                   params[:tagnames].split(',')
                 else
                   params[:tagnames]
                 end
      if current_user
        if params[:type] == "tag"
          tag_list.each do |t|
            next unless t.length.positive?

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
                redirect_to return_to
                return false
              end
            end
            # test for uniqueness
            unless TagSelection.where(following: true, user_id: current_user.uid, tid: tag.tid).length.positive?
              # Successfully we have added subscription
              set_following(true, params[:type], tag.tid)
            end
          end
          respond_with do |format|
            format.html do
              if request.xhr?
                render json: true
              else
                tagnames = params[:tagnames].class == Array ? params[:tagnames].join(', ') : params[:tagnames]
                flash[:notice] = "You are now following #{tagnames}."
                redirect_to return_to
              end
            end
          end
        end
      else
        flash[:warning] = "You must be logged in to subscribe for email updates!"
        redirect_to "/login?return_to=" + request.fullpath
      end
    end
  end

  private

  def tag_selection_more_than_zero?(tag_id)
    TagSelection.where(following: true, user_id: current_user.uid, tid: tag_id).length.positive?
  end

  def set_following(value, type, id)
    # add swtich statement for different types: tag, node, user
    if type == 'tag' && Tag.find_by(tid: id)
      # Create the entry if it isn't already created.
      # assume tag, for now:
      subscription = TagSelection.where(user_id: current_user.uid,
                                        tid: id).first_or_create
      subscription.following = value

      # Check if the value changed.
      if subscription.following_changed?
        # tag = Tag.find(id)
        # we have to implement caching for tags if we want to adapt this code:
        # if subscription.following
        #  node.cached_likes = node.cached_likes + 1
        # else
        #  node.cached_likes = node.cached_likes - 1
        # end

        # Save the changes.
        # ActiveRecord::Base.transaction do
        #  tag.save!
        subscription.save!
        # end
      end
      subscription.following
    else
      flash.now[:error] = "There was an error."
      false
    end
  end
end
