class LegacyController < ApplicationController

  def notes
    if params[:id]
      redirect_to "/tag/"+params[:id], :status => 301
    else
      redirect_to "/research", :status => 301
    end
  end

  def note_add 
    redirect_to "/post", :status => 301
  end

  def page_add 
    redirect_to "/wiki/new", :status => 301
  end

  def people
    redirect_to '/profile/'+params[:id], :status => 301
  end

  def place
    redirect_to "/wiki/"+params[:id], :status => 301
  end

  def tool
    redirect_to "/wiki/"+params[:id], :status => 301
  end

  def openid
    user = User.find params[:id]
    redirect_to "/openid/"+user.username, :status => 301
  end

  def openid_username
    redirect_to "/openid/"+params[:username], :status => 301
  end

  def file
    # http://publiclab.org/sites/default/files/Public%20Lab.pdf
    redirect_to "http://old.publiclab.org/sites/default/files/"+params[:filename]+"."+params[:format], :status => 301
  end

  def image
    # sites/default/files/imagecache/thumb/san-martin-spectro.jpg
    redirect_to "http://old.publiclab.org/sites/default/files/imagecache/"+params[:size]+"/"+params[:filename]+"."+params[:format], :status => 301
  end

  def register
    redirect_to "/signup", :status => 301
  end

  # http://publiclaboratory.org/node/5853
  def node
    node = DrupalNode.find params[:id]
    redirect_to node.path, :status => 301
  end

  def report
    @node = DrupalUrlAlias.find_by_dst('report/'+params[:id]).node
    redirect_to "/notes/"+@node.author.name.downcase+'/'+Time.at(@node.created_at).strftime("%m-%d-%Y")+'/'+params[:id], :status => 301
  end

  def rss
    redirect_to "/feed.rss", :status => 301
  end


end
