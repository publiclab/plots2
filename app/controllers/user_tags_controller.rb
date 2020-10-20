class UserTagsController < ApplicationController
  respond_to :html, :xml, :json, :js

  require 'will_paginate/array'

  def index
    @toggle = params[:sort] || "uses"

    @title = I18n.t('tag_controller.tags')
    @paginated = true
    if params[:search]
      keyword = params[:search]
      @pagy, @user_tags = pagy_array(UserTag
        .select('value')
        .where("value LIKE :keyword", keyword: "%#{keyword}%")
        .group(:value)
        .order('value ASC')
        .count('value').to_a, items: 24)
    elsif @toggle == "value"
      @pagy, @user_tags = pagy_array(UserTag.group(:value)
        .select('value')
        .order('value ASC')
        .count('value').to_a, items: 24)
    else # @toggle == "uses"
      @pagy, @user_tags = pagy_array(UserTag.group(:value)
        .select('value')
        .order('count_value DESC')
        .count('value').to_a, items: 24)
    end
  end

  def create
    @output = {
      errors: [],
      saved: []
    }
    exist = false

    user = User.find(params[:id])

    if current_user && current_user == user || logged_in_as(['admin'])
      if params[:name]
        tagnames = params[:name].split(',')
        tagnames.each do |tagname|
          name = tagname.downcase
          if UserTag.exists?(current_user.id, name)
            @output[:errors] << I18n.t('user_tags_controller.tag_already_exists')
            exist = true
          end

          next if exist

          user_tag = user.user_tags.build(value: name)
          if tagname.split(':')[1] == "facebook"
            @output[:errors] << "This tag is used for associating a Facebook account. <a href='https://publiclab.org/wiki/oauth'>Click here to read more </a>"
          elsif  tagname.split(':')[1] == "github"
            @output[:errors] << "This tag is used for associating a Github account. <a href='https://publiclab.org/wiki/oauth'>Click here to read more </a>"
          elsif  tagname.split(':')[1] == "google_oauth2"
            @output[:errors] << "This tag is used for associating a Google account. <a href='https://publiclab.org/wiki/oauth'>Click here to read more </a>"
          elsif  tagname.split(':')[1] == "twitter"
            @output[:errors] << "This tag is used for associating a Twitter account. <a href='https://publiclab.org/wiki/oauth'>Click here to read more </a>"
          elsif user_tag.save
            @output[:saved] << [name, user_tag.id, params[:id]]
          else
            @output[:errors] << I18n.t('user_tags_controller.cannot_save_value')
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
      redirect_to URI.parse('/profile/' + user.username).path
    end
  end

  def delete
    output = {
      status: false,
      tid: 0,
      errors: []
    }

    @user_tag = UserTag.where(uid: params[:id], value: params[:name]).first

    if !@user_tag.nil?
      if logged_in_as(['admin']) || @user_tag.user == current_user
        UserTag.where(uid: params[:id], value: params[:name]).destroy_all
        output[:errors] = I18n.t('user_tags_controller.tag_deleted')
        output[:status] = true
      else
        output[:errors] = I18n.t('user_tags_controller.admin_user_manage_tags')
      end
    else
      output[:errors] = I18n.t('user_tags_controller.tag_doesnt_exist')
    end

    output[:tid] = @user_tag&.id
    if request.xhr?
      render json: output
    else
      if output[:status]
        flash[:notice] = output[:errors]
      else
        flash[:error] = output[:errors]
      end
      redirect_to info_path
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
