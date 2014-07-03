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

end
