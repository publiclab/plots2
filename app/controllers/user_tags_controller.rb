class UserTagsController < ApplicationController
  include UserTagsHelper
  respond_to :html, :xml, :json, :js
  def create
    tags = ['skill', 'gear', 'role', 'tool', 'language']
    @output = {
      errors: [],
      saved: []
    }
    exist = false
    isLanguage = false

    user = User.find_by_username(params[:id])

    if current_user.role == "admin" || current_user == user
      if params[:type] && tags.include?(params[:type])
        if params[:value] != ""
          value = params[:type] + ":" + params[:value]
          if UserTag.exists?(user.id, value)
            @output[:errors] << I18n.t('user_tags_controller.tag_already_exists')
            exist = true
          end
          
          if !exist && params[:type] == "language"
            locale_array = locale_name_pairs.keys.map!(&:downcase)
            
            if locale_array.include?(params[:value].downcase)
              value = params[:type] + ":" + params[:value].capitalize
              user_tag = user.user_tags.build(value: value)
              if user_tag.save
                @output[:saved] = [user_tag.id, value.split(":")[0], value.split(":")[1]]
                lang = locale_name_pairs[params[:value].capitalize]
                cookies.permanent[:plots2_locale] = lang
                I18n.locale = lang
              else
                @output[:errors] << "Error: Cannot save value. Try Again"
              end
            else
              locale_string = locale_array.map { |locale| locale.capitalize }.join(", ")
              @output[:errors] << "Error: Unsupported language. [Supported languages: " + locale_string.to_s + "]"
            end
            isLanguage=true
          end
          
          if !exist && !isLanguage
            user_tag = user.user_tags.build(value: value)
            if user_tag.save
              @output[:saved] = [user_tag.id, value.split(":")[0], value.split(":")[1]]
            else
              @output[:errors] << I18n.t('user_tags_controller.cannot_save_value')
            end
          end
        else
          @output[:errors] << I18n.t('user_tags_controller.value_cannot_be_empty')
        end
      else
        @output[:errors] << I18n.t('user_tags_controller.invalid_value', :type => params[:type]).html_safe
      end
    else
      @output[:errors] << I18n.t('user_tags_controller.admin_user_manage_tags')
    end

    respond_with do |format|
      format.html do
        if request.xhr?
          render json: @output
        else
          if @output[:errors].length > 0
            flash[:error] = I18n.t('user_tags_controller.errors_occured', :count => @output[:errors].length).html_safe
          else
            flash[:notice] = I18n.t('user_tags_controller.tag_created', :tag_name => @output[:saved][2]).html_safe
          end
          redirect_to info_path, :id => params[:id]
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
      if current_user.role == "admin" || @user_tag.user == current_user
        if @user_tag
          @user_tag.destroy
          message = I18n.t('user_tags_controller.tag_deleted')
          output[:status] = true
        else
          output[:status] = false
          message = I18n.t('user_tags_controller.tag_doesnt_exist')
        end
      else
        message = I18n.t('user_tags_controller.admin_user_manage_tags')
      end
    rescue ActiveRecord::RecordNotFound
      output[:status] = false
      message = I18n.t('user_tags_controller.tag_doesnt_exist')
    end

    output[:errors] << message
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
