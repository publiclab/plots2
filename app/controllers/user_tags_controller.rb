class UserTagsController < ApplicationController
  respond_to :html, :xml, :json
  def create
    tags = ['skill', 'gear', 'role', 'tool']
    @output = {
      errors: [],
      saved: []
    }
    exist = false

    if params[:type] && tags.include?(params[:type])
      if params[:value]
        value = params[:type] + ":" + params[:value]
        if UserTag.exists?(current_user.id, value)
          @output[:errors] << "Error: tag already exists."
          exist = true
        end

        if !exist
          user_tag = current_user.user_tags.build(value: value)
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
      @output[:errors] << "Error: Invalid value #{param[:type]}"
    end

    respond_with do |format|
      format.html do
        if request.xhr?
          render json: @output
        else
          if @output.errors.length > 0
            flash[:error] = "#{@output[:errors].length} errors occured."
          else
            flash[:notice] = "#{@output[:saved][2]} tag created successfully"
          end
          redirect_to info_path
        end
      end
    end
  end

  def suggested
    if params[:id].length > 0
      suggested = []

      UserTag.where('value LIKE ?', "%" + params[:id] + "%").each do |tag|
        suggested << tag.value#.split(":")[1]
      end
      render json: suggested.uniq
    else
      render json: []
    end
  end
end
