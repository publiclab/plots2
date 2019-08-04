class CsvfilesController < ApplicationController
  before_action :require_user, only: %i(delete user_files)

  def new
    # to render the index page of simple-data-grapher
  end

  def setter
    @csvfile = Csvfile.new(
      uid: params[:uid],
      filetitle: params[:filetitle],
      filedescription: params[:filedescription],
      filepath: params[:object],
      filename: "file" + Time.now.to_i.to_s,
      filestring: params[:filestring]
    )
    render json: @csvfile if @csvfile.save
  end

  def prev_files
    @allfile = Csvfile.where(uid: params[:uid])
    render json: @allfile
  end

  def user_files
    @user_files = Csvfile.where(uid: params[:id])
  end

  def add_graphobject
    @newfile = Csvfile.new(
        uid: params[:uid],
        filetitle: params[:filetitle],
        filedescription: params[:filedescription],
        filepath: params[:object],
        filename: "file" + Time.now.to_i.to_s,
        filestring: params[:filestring],
        graphobject: params[:graphobject]
    )
    @newfile.save
    render json: {uid: params[:uid], id: @newfile.id}
  end

  def delete
    return unless params[:id] && params[:uid].to_i == current_user.uid
    file = Csvfile.where(id: params[:id].to_i)
    if file.destroy(params[:id].to_i)
      flash[:notice] = "Deleted the file"
    else
      flash[:error] = "Could not delete the file"
    end
    redirect_to "simple-data-grapher/data/#{params[:uid]}"
  end

  def fetch_graphobject
    @graphobject = Csvfile.where(id: params[:id].to_i, uid: params[:uid].to_i)
    render json: {sdgobject: @graphobject[0].graphobject}
  end
end
