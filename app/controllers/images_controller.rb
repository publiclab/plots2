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
    @image.nid = DrupalNode.find(params[:nid].to_i).nid unless params[:nid].nil? || params[:nid] == "undefined"
    if @image.save!
      #@image = Image.find @image.id
      if request.xhr?
        render :json => { :filename => @image.photo_file_name,
                          :url => @image.path,
                          :id => @image.id
                        }
      else
        flash[:notice] = "Image saved."
        redirect_to @node.path
      end
    else
      flash[:error] = "The image could not be saved."
      redirect_to "/images/new"
    end
  end

  def new
    @image = Image.new()
  end

  # Jeff believes this is not used.
  def update
    @image = Image.find params[:id]
    # make changes
    if @image.save
      flash[:notice] = "Image updated."
    else
      flash[:error] = "The image could not be updated."
    end
    redirect_to "/post"
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
