class FeaturesController < ApplicationController
  before_filter :require_user

  def index
    @features = DrupalNode.where(:type => 'feature').paginate(:page => params[:page])
  end

  def new
    if current_user.role != "admin"
      flash[:warning] = "Only admins may edit features."
      redirect_to "/features"
    end
  end

  def edit
    if current_user.role != "admin"
      flash[:warning] = "Only admins may edit features."
      redirect_to "/features"
    else
      @node = DrupalNode.find params[:id]
    end
  end

  def create
    if current_user.role != "admin"
      flash[:warning] = "Only admins may edit features."
      redirect_to "/features"
    else
      node = DrupalNode.new({
        :uid =>     current_user.id,
        :title =>   params[:title],
        :type =>    "feature"
      })
      if node.valid?
        saved = true
        revision = false
        ActiveRecord::Base.transaction do
          node.save! 
          revision = node.new_revision({
            :nid => node.id,
            :uid => current_user.id,
            :title => params[:title],
            :body => params[:body]
          })
          if revision.valid?
            revision.save!
            node.vid = revision.vid
            node.save!
          else
            saved = false
            node.destroy
          end
        end
      end
      if saved
        flash[:notice] == "Feature saved."
        redirect_to "/features"
      else
        render :template => "features/new"
      end
    end
  end

  def update
    if current_user.role != "admin"
      flash[:warning] = "Only admins may edit features."
      redirect_to "/features"
    else
      @node = DrupalNode.find(params[:id])
      @revision = @node.new_revision({
        :nid => @node.id,
        :uid => current_user.uid,
        :title => params[:title],
        :body => params[:body]
      })
      if @revision.valid?
        ActiveRecord::Base.transaction do
          @revision.save
          @node.vid = @revision.vid
          @node.title = @revision.title
          @node.save
        end
        flash[:notice] = "Edits saved."
        redirect_to "/features"
      else
        flash[:error] = "Your edit could not be saved."
        render :action => :edit
      end
    end
  end

end
