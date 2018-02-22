class UserTagsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def create

    @output = {
      errors: [],
      saved: []
    }
    exist = false

    user = User.find(params[:id])

    if current_user && (current_user.role == 'admin' || current_user == user)
      if params[:name]
        tagnames = params[:name].split(',')
        tagnames.each do |tagname|
          name = tagname.downcase
          if UserTag.exists?(current_user.id, name)
            @output[:errors] << I18n.t('user_tags_controller.tag_already_exists')
            exist = true
          end
 
          unless exist
            user_tag = user.user_tags.build(value: name)
            if user_tag.save
              @output[:saved] << [name, user_tag.id]
            else
              @output[:errors] << I18n.t('user_tags_controller.cannot_save_value')
            end
          end
        end
      else
        @output[:errors] << I18n.t('user_tags_controller.value_cannot_be_empty')
      end
    else
      @output[:errors] << I18n.t('user_tags_controller.admin_user_manage_tags')
    end

    if request.xhr?
      render json: @output
    else
      if !@output[:errors].empty?
        flash[:error] = I18n.t('user_tags_controller.errors_occured', count: @output[:errors].length).html_safe
      else
        flash[:notice] = I18n.t('user_tags_controller.tag_created', tag_name: @output[:saved][0][0]).html_safe
      end
      redirect_to '/profile/' + user.username
    end
  end

  def delete
    output = {
      status: false,
      errors: []
    }
    message = ''

    begin  
      @user_tag = UserTag.where(uid: params[:id], value: params[:name])
      if(!@user_tag.nil?)
          @user_tag = @user_tag.first 
      end 
  
      if current_user.role == 'admin' || params[:id].to_i == current_user.id
        if (!@user_tag.nil? && @user_tag.user == current_user) || (!@user_tag.nil? && current_user.role == 'admin')
          UserTag.where(uid: params[:id] , value: params[:name]).destroy_all    
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
    if !params[:name].empty?
      suggested = []
      UserTag.where('value LIKE ?', params[:name] + '%').each do |tag|
        suggested << tag.value
      end
      render json: suggested.uniq
    else
      render json: []
    end
  end
end
