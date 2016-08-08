class QuestionsController < ApplicationController

  def index
    @title = "Recent Questions"
    @notes = DrupalNode.where(status: 1, type: 'note')
                       .joins(:drupal_tag)
                       .where('term_data.name LIKE ?', 'question:%')
                       .order('node.nid DESC')
                       .group('node.nid')
                       .paginate(:page => params[:page], :per_page => 30)
    @wikis = DrupalNode.limit(10)
                       .where(type: 'page', status: 1)
                       .order("nid DESC")
  end

  def show
    if params[:author] && params[:date]
      @node = DrupalNode.find_notes(params[:author], params[:date], params[:id])
      @node = @node || DrupalNode.where(path: "/report/#{params[:id]}").first
      if request.path != @node.path(:question)
        return redirect_to @node.path(:question), :status => :moved_permanently
      end
    else
      @node = DrupalNode.find params[:id]
    end

    unless @node.has_power_tag('question')
      flash[:error] = "Not a question"
      redirect_to "/"
    end

    alert_and_redirect_moderated

    @node.view
    @title = @node.latest.title
    @tags = @node.tags
    @tagnames = @tags.collect(&:name)

    set_sidebar :tags, @tagnames
  end

  def shortlink
    @node = DrupalNode.find params[:id]
    redirect_to @node.path(:question)
  end

  def popular
    @title = "Popular Questions"
    @notes = DrupalNode.where(status: 1, type: 'note')
                       .joins(:drupal_tag)
                       .where('term_data.name LIKE ?', 'question:%')
                       .order('node_counter.totalcount DESC')
                       .includes(:drupal_node_counter)
                       .group('node.nid')
                       .limit(20)
    @wikis = DrupalNode.limit(10)
                       .where(type: 'page', status: 1)
                       .order("nid DESC")
    @unpaginated = true
    render :template => 'questions/index'
  end

  def liked
    @title = "Highly liked Questions"
    @notes = DrupalNode.where(status: 1, type: 'note')
                       .joins(:drupal_tag)
                       .where('term_data.name LIKE ?', 'question:%')
                       .order("cached_likes DESC")
                       .group('node.nid')
                       .limit(20)
    @wikis = DrupalNode.limit(10)
                       .where(type: 'page', status: 1)
                       .order("nid DESC")
    @unpaginated = true
    render :template => 'questions/index'
  end
end
