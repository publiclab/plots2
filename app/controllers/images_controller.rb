require 'open-uri'

class ImagesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :require_user, only: %i(create new update delete)

  def shortlink
    params[:size] = params[:size] || params[:s]
    params[:size] = params[:size] || :large
    params[:size] = :thumb if (params[:size].to_s == "t")
    params[:size] = :thumb if (params[:size].to_s == "thumbnail")
    params[:size] = :medium if (params[:size].to_s == "m")
    params[:size] = :large if (params[:size].to_s == "l")
    params[:size] = :original if (params[:size].to_s == "o")
    image = Image.find(params[:id])
    redirect_to URI.parse(image.path(params[:size])).path
  end

  def create
    if params[:i]
      @image = Image.new(remote_url: params[:i],
                         uid: current_user.uid)
      flash[:error] = 'The image could not be saved.' unless @image.save!
    elsif params[:data]
      filetype = params[:data].split(';').first.split('/').last
      @image = Image.new(uid: current_user.uid,
                         photo: params[:data],
                         photo_file_name: 'dataurl.' + filetype)
      @image.save!
    else
      @image = Image.new(uid: current_user.uid,
                         photo: params[:image][:photo],
                         title: params[:image][:title],
                         notes: params[:image][:notes])
    end
    @image.nid = Node.find(params[:nid].to_i).nid unless params[:nid].nil? || params[:nid] == 'undefined'
    if @image.save!
      render json: {
        id: @image.id,
        url: @image.shortlink,
        full: 'https://' + request.host.to_s + '/' + @image.path(:large),
        filename: @image.photo_file_name,
        href: @image.shortlink, # Woofmark/PublicLab.Editor
        title: @image.photo_file_name,
        results: [{ # Woofmark/PublicLab.Editor
          href: @image.shortlink + "." + @image.filetype,
          title: @image.photo_file_name
        }]
      }
    else
      render plain: 'The image could not be saved.'
    end
  end

  def new
    @image = Image.new
  end

  def delete
    @image = Image.find params[:id]
    if @image.uid == current_user.uid # or current_user.role == "admin"
      if @image.delete
        flash[:notice] = 'Image deleted.'
      else
        flash[:error] = 'The image could not be deleted.'
      end
      redirect_to '/post'
    else
      prompt_login 'Only the owner can delete this image.'
    end
  end
end
