class CsvfilesController < ApplicationController
    #before user authentication PROBLEM!!
    before_action :require_user, only: %i(delete user_files)
    def new
        
    end
    def setter
        @csvfile = Csvfile.new(
            uid: params[:uid],
            filetitle: params[:filetitle],
            filedescription: params[:filedescription],
            filepath: params[:object],
            filename: "file"+Time.now.to_i.to_s,
            filestring: params[:filestring]
        )
        # byebug
        if @csvfile.save
            flash[:notice] = "Saved!!"
            render :json => @csvfile
        end
    end
    def prev_files
        @allfile=Csvfile.where(uid: params[:uid])
        render :json => @allfile
        # byebug
    end
    def user_files
        @user_files=Csvfile.where(uid: params[:id])
        # byebug
    end
    def delete
        if params[:id] && params[:uid].to_i==current_user.uid
            file=Csvfile.where(id: params[:id].to_i)
            # byebug
            if file.destroy(params[:id].to_i)
                flash[:notice] = "Deleted the file"
                redirect_to '/simple-data-grapher/data/'+params[:uid]
            else
                flash[:error] = "Could not delete the file"
                redirect_to '/simple-data-grapher/data/'+params[:uid]
            end
        end
    end
end
