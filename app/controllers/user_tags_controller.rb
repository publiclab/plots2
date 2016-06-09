class UserTagsController < ApplicationController
  respond_to :html, :xml, :json, :js
  def create
    tags = ['skill', 'gear', 'role', 'tool']
    @output = {
      errors: [],
      saved: []
    }
    exist = false

    user = User.find_by_username(params[:id])
    if params[:type] && tags.include?(params[:type])
      if params[:value] != ""
        value = params[:type] + ":" + params[:value]
        if UserTag.exists?(user.id, value)
          @output[:errors] << "Error: tag already exists."
          exist = true
        end

        if !exist
          user_tag = user.user_tags.build(value: value)
          if user_tag.save
            @output[:saved] = [user_tag.id, value.split(":")[0], value.split(":")[1]]
          else
            @output[:errors] << "Error: Cannot save value. Try Again"
          end
        end
      else
        @output[:errors] << "Error: value cannot be empty"
      end
    else
      @output[:errors] << "Error: Invalid value #{params[:type]}"
    end

    respond_with do |format|
      format.html do
        if request.xhr?
          render json: @output
        else
          if @output[:errors].length > 0
            flash[:error] = "#{@output[:errors].length} errors occured."
          else
            flash[:notice] = "#{@output[:saved][2]} tag created successfully"
          end
          redirect_to info_path
        end
      end
    end
  end

  def delete
    output = {
      status: false,
      errors: []
    }
    message = ""

    begin
      @user_tag = UserTag.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      output[:status] = false
      message = "Tag doesn't exist."
    end
    if @user_tag
      @user_tag.destroy
      message = "Tag deleted."
      output[:status] = true
    else
      output[:status] = false
      message = "Tag doesn't exist."
    end
    respond_with do |format|
      format.js
      format.html do
        if request.xhr?
          render json: output
        else
          if output[:status]
            flash[:notice] = message
          else
            flash[:error] = message
          end
          redirect_to info_path
        end
      end
    end
  end

  def suggested
    if params[:value].length > 0
      suggested = []

      UserTag.where('value LIKE ?', params[:key] + ":" + "%"+ params[:value] +"%").each do |tag|
        suggested << tag.value.split(":")[1]
      end
      render json: suggested.uniq
    else
      render json: []
    end
  end
end
