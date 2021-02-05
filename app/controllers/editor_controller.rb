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

  def new
    @node = Node.find(node_id)
    @revision = @node.revision.first
    params[:body] = @node.body
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

    # if user has a location, set the @lat and @lon
    if @lat.nil? && @lon.nil? && current_user&.has_power_tag("lat") && current_user&.has_power_tag("lon")
      @lat = current_user.get_value_of_power_tag("lat").to_f
      @lon = current_user.get_value_of_power_tag("lon").to_f
      @map_blurred = current_user.has_tag('location:blurred')
      if @zoom.nil? && current_user&.has_power_tag("zoom")
        @zoom = current_user.get_value_of_power_tag("zoom")
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
