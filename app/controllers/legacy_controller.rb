class LegacyController < ApplicationController

  def notes
    if params[:id]
      redirect_to "/tag/"+params[:id]
    else
      redirect_to "/research"
    end
  end

  def note_add 
    redirect_to "/post"
  end

  def page_add 
    redirect_to "/wiki/new"
  end

  def people
    redirect_to '/profile/'+params[:id]
  end

  def place
    redirect_to "/wiki/"+params[:id]
  end

  def tool
    redirect_to "/wiki/"+params[:id]
  end

  def openid
    user = User.find params[:id]
    redirect_to "/openid/"+user.username
  end

  def openid_username
    redirect_to "/openid/"+params[:username]
  end

  def file
    # http://publiclab.org/sites/default/files/Public%20Lab.pdf
    redirect_to "http://old.publiclab.org/sites/default/files/"+params[:filename]+"."+params[:format]
  end

  def image
    # sites/default/files/imagecache/thumb/san-martin-spectro.jpg
    redirect_to "http://old.publiclab.org/sites/default/files/imagecache/"+params[:size]+"/"+params[:filename]+"."+params[:format]
  end
end
