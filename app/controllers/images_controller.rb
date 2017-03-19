require 'open-uri'

class ImagesController < ApplicationController

  respond_to :html, :xml, :json
  before_filter :require_user, :only => [:create, :new, :update, :delete]

  def create
    if params[:i]
      @image = Image.new({
        :remote_url => params[:i],
        :uid => current_user.uid
      })
      flash[:error] = "The image could not be saved." unless @image.save!
    else
      @image = Image.new({
        :uid => current_user.uid,
        :photo => params[:image][:photo],
        :title => params[:image][:title],
        :notes => params[:image][:notes]
      })
    end
    @image.nid = Node.find(params[:nid].to_i).nid unless params[:nid].nil? || params[:nid] == "undefined"
    if @image.save!
      render :json => { 
        id:       @image.id,
        url:      @image.path(:large),
        filename: @image.photo_file_name,
        href:     @image.path(:large), # Woofmark/PublicLab.Editor
        title:    @image.photo_file_name,
        results:  [{ # Woofmark/PublicLab.Editor
                    href:  @image.path(:large),
                    title: @image.photo_file_name
                  }]
      }
    else
      render text: "The image could not be saved."
    end
  end

  def new
    @image = Image.new()
  end

  def delete
    @image = Image.find params[:id]
    if @image.uid == current_user.uid # or current_user.role == "admin" 
      if @image.delete
        flash[:notice] = "Image deleted."
      else
        flash[:error] = "The image could not be deleted."
      end
      redirect_to "/post"
    else
      prompt_login "Only the owner can delete this image."
    end
  end

end
