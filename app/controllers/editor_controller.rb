class EditorController < ApplicationController

  before_filter :require_user, :only => [:post]

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
  end

  def rich
    if params[:main_image] && Image.find_by_id(params[:main_image])
      @main_image = Image.find_by_id(params[:main_image]).path
    end
  end

end
