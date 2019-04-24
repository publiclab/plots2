class LegacyController < ApplicationController
  def notes
    if params[:id]
      redirect_to URI.parse('/tag/' + params[:id]).path, status: 301
    else
      redirect_to '/research', status: 301
    end
  end

  def note_add
    redirect_to '/post', status: 301
  end

  def page_add
    redirect_to '/wiki/new', status: 301
  end

  def people
    redirect_to URI.parse('/profile/' + params[:id]).path, status: 301
  end

  def place
    redirect_to URI.parse('/wiki/' + params[:id]).path, status: 301
  end

  def tool
    redirect_to URI.parse('/wiki/' + params[:id]).path, status: 301
  end

  def openid
    user = User.find params[:id]
    redirect_to URI.parse('/openid/' + user.username).path, status: 301
  end

  def openid_username
    if params[:provider]
      # if with the open id through provider
      redirect_to URI.parse('/openid/' + params[:username] + '/' + params[:provider]).path, status: 301
    else
      # login without provider with openid
      redirect_to URI.parse('/openid/' + params[:username]).path, status: 301
    end
  end

  def file
    redirect_to URI.parse("//#{request.host}/sites/default/files/" + params[:filename] + '.' + params[:format]).path, status: 301
  end

  def register
    redirect_to '/signup', status: 301
  end

  # /node/5853
  def node
    node = Node.find params[:id]
    redirect_to URI.parse(node.path).path, status: 301
  end

  def report
    node = Node.find_by(slug: params[:id])
    redirect_to URI.parse(node.path).path, status: 301
  end

  def rss
    redirect_to '/feed.rss', status: 301
  end
end
