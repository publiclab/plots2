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

    if params[:tags]&.include? "lat:" and params[:tags]&.include? "lon:"
      tags = params[:tags].split(',')
      tags.each do |x|
        x.include? "lat:" and (@lat = x.split(':')[1])
        x.include? "lon:" and (@lon = x.split(':')[1])
        x.include? "zoom:" and (@zoom = x.split(':')[1])
      end
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
