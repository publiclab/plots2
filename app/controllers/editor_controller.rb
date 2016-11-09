class EditorController < ApplicationController

  before_filter :require_user, :only => [:post, :rich]

  # main image via URL passed as GET param
  def post
    # /post/?i=http://myurl.com/image.jpg
    if params[:i]
      @image = Image.new({
        :remote_url => params[:i],
        :uid => current_user.uid
      })
      flash[:error] = "The image could not be saved." unless @image.save!
    end
<<<<<<< HEAD
    redirect_to '/questions/new' if params[:tags] && params[:tags].include?("question:")
=======
    redirect_to "/questions/new?#{request.env['QUERY_STRING']}" if params[:tags] && params[:tags].include?("question:")
>>>>>>> 2e77bd95c9873daa8608b348e891c27daf34ac2f
  end

  def rich
    if params[:main_image] && Image.find_by_id(params[:main_image])
      @main_image = Image.find_by_id(params[:main_image]).path
    end
  end

end
