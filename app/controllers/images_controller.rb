class ImagesController < ApplicationController
  respond_to :html, :xml, :json

  def create
    if current_user && current_user.username == "warren"
      params[:image][:title] = "Untitled" if params[:image][:title].nil?
      @image = Image.new({
        :uid => current_user.uid,
        :photo => params[:image][:photo],
        :title => params[:image][:title],
        :notes => params[:image][:notes]
      })
      @image.nid = DrupalNode.find params[:nid] if params[:nid]
      if @image.save!
        #@image = Image.find @image.id
        if request.xhr?
          render :json => {:url => @image.photo.url(:thumb),:id => @image.id}
        else
          flash[:notice] = "Image saved."
          redirect_to @node.path
        end
      else
        flash[:error] = "The image could not be saved."
        redirect_to "/images/new"
      end
    else
      prompt_login "You must be logged in to upload."
    end
  end

  def new
    @image = Image.new()
  end

  def update
    if current_user && current_user.username == "warren"
      @image = Image.find params[:id]
      # make changes
      if @image.save
        flash[:notice] = "Image updated."
      else
        flash[:error] = "The image could not be updated."
      end
      redirect_to "/post"
    else
      prompt_login "You must be logged in to edit images."
    end
  end

  def delete
    if current_user && current_user.username == "warren"
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
    else
      prompt_login "You must be logged in to delete images."
    end
  end

end
