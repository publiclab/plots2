class FeaturesController < ApplicationController
  before_filter :require_user, :except => [ :embed ]

  def index
    @features = Node.where(:type => 'feature')
                          .paginate(:page => params[:page])
  end

  def embed
    @node = Node.find_by_title params[:id]
    render :layout => false
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
      @node = Node.find params[:id]
    end
  end

  def create
    if current_user.role != "admin"
      flash[:warning] = "Only admins may edit features."
      redirect_to "/features?_=" + Time.now.to_i.to_s
    else
      @node = Node.new({
        uid:   current_user.id,
        title: params[:title],
        type:  "feature"
      })
      if @node.valid?
        saved = true
        @revision = false
        ActiveRecord::Base.transaction do
          @node.save! 
          @revision = @node.new_revision({
            uid:   current_user.id,
            title: params[:title],
            body:  params[:body]
          })
          if @revision.valid?
            @revision.save!
            @node.vid = @revision.vid
            @node.save!
          else
            saved = false
            @node.destroy
          end
        end
      end
      if saved
        flash[:notice] = "Feature saved."
        redirect_to "/features?_=" + Time.now.to_i.to_s
      else
        render template: "features/new"
      end
    end
  end

  def update
    if current_user.role != "admin"
      flash[:warning] = "Only admins may edit features."
      redirect_to "/features?_=" + Time.now.to_i.to_s
    else
      @node = Node.find(params[:id])
      @revision = @node.new_revision({
        uid:   current_user.uid
      })
      @revision.title = params[:title] || @node.latest.title
      @revision.body = params[:body] if params[:body]
      if @revision.valid?
        ActiveRecord::Base.transaction do
          @revision.save
          @node.vid = @revision.vid
          @node.title = @revision.title
          @node.save
        end
        expire_fragment("feature_#{params[:title]}")
        flash[:notice] = "Edits saved and cache cleared."
        redirect_to "/features?_=" + Time.now.to_i.to_s
      else
        flash[:error] = "Your edit could not be saved."
        render action: 'edit'
      end
    end
  end

end
