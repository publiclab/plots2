class EditorController < ApplicationController

  before_filter :require_user, :only => [:post, :rich, :legacy, :editor]

  # main image via URL passed as GET param
  def legacy
    # /post/?i=http://myurl.com/image.jpg
    flash.now[:notice] = "This is the legacy editor. For the new rich editor, <a href='/editor'>click here</a>."
    if params[:i]
      @image = Image.new({
        :remote_url => params[:i],
        :uid => current_user.uid
      })
      flash[:error] = "The image could not be saved." unless @image.save!
    end
    if params[:n] && !params[:body] # use another node body as a template
      node = Node.find(params[:n])
      params[:body] = node.body if node
    end
    if params[:tags] && params[:tags].include?("question:")
      redirect_to "/questions/new?#{request.env['QUERY_STRING']}"
    else
      render template: 'editor/post'
    end
  end

  def editor
    redirect_to "/post?#{request.env['QUERY_STRING']}"
  end

  def post
    if params[:tags] && params[:tags].include?("question:")
      redirect_to "/questions/new?#{request.env['QUERY_STRING']}"
    elsif params[:legacy] || params[:template] == "event"
      legacy
    else
      rich
      render "/editor/rich"
    end
  end

  def rich
    flash.now[:notice] = "This is the new rich editor. For the legacy editor, <a href='/post?#{request.env['QUERY_STRING']}&legacy=true'>click here</a>."
    if params[:main_image] && Image.find_by_id(params[:main_image])
      @main_image = Image.find_by_id(params[:main_image]).path
    end
    if params[:n] && !params[:body] # use another node body as a template
      node = Node.find(params[:n])
      params[:body] = node.body if node
    end
  end

end
