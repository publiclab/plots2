class EditorController < ApplicationController
  before_action :require_user, only: %i(post rich legacy editor)

  # main image via URL passed as GET param
  def legacy
    # /post/?i=http://myurl.com/image.jpg
    flash.now[:notice] = "This is the legacy editor. For the new rich editor, <a href='/editor'>click here</a>."
    flash.now[:warning] = "Deprecation notice: Legacy editor will be discontinued soon, please use rich/markdown editor."
    image if params[:i]
    template if params[:n] && !params[:body] # use another node body as a template
    if params[:tags]&.include?('question:')
      redirect_to "/questions/new?#{request.env['QUERY_STRING']}"
    else
      render template: 'editor/post'
    end
  end

  def editor
    redirect_to "/post?#{request.env['QUERY_STRING']}"
  end

  def post
    @graphobject = [params[:id], params[:uid]] if params[:id] && params[:uid]
    if params[:tags]&.include?('question:')
      redirect_to "/questions/new?#{request.env['QUERY_STRING']}"
    elsif params[:legacy] || params[:template] == 'event'
      legacy
    else
      rich
      render '/editor/rich'
    end
  end

  def rich
    if params[:main_image] && Image.find_by(id: params[:main_image])
      @main_image = Image.find_by(id: params[:main_image]).path
    end
    template if params[:n] && !params[:body] # use another node body as a template
    image if params[:i]
  end

  private

  def image
    @image = Image.new(remote_url: params[:i],
                       uid: current_user.uid)
    flash[:error] = 'The image could not be saved.' unless @image.save!
  end

  def template
    node = Node.find(params[:n])
    params[:body] = node.body if node
  end
end