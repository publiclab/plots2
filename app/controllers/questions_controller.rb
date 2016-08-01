class QuestionsController < ApplicationController

  def index
    @title = "Recent Questions"
    @questions = DrupalNode.where(status: 1, type: 'note')
                       .joins(:drupal_tag)
                       .where('term_data.name LIKE ?', 'question:%')
                       .order('node.nid DESC')
                       .group('node.nid') 
    sort_question_by_tags
    @questions = @questions.paginate(:page => params[:page], :per_page => 30)

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
      redirect_to @node.path
    end

    alert_and_redirect_moderated

    @node.view
    @title = @node.latest.title
    @tags = @node.power_tag_objects('question')
    @tagnames = @tags.collect(&:name)
    @users = @node.answers.group(:uid)
                  .order('count(*) DESC')
                  .collect(&:author)

    set_sidebar :tags, @tagnames
  end

  def answered
    @title = "Recently answered"
    @questions = DrupalNode.joins(:answers)
                       .order('answers.created_at DESC')
                       .group('node.nid')
    sort_question_by_tags
    @questions = @questions.paginate(:page => params[:page], :per_page => 30)

    @wikis = DrupalNode.limit(10)
                       .where(type: 'page', status: 1)
                       .order("nid DESC")
    render :template => 'questions/index'
  end

  def shortlink
    @node = DrupalNode.find params[:id]
    if @node.has_power_tag('question')
      redirect_to @node.path(:question)
    else
      redirect_to @node.path
    end
  end

  def popular
    @title = "Popular Questions"
    @questions = DrupalNode.where(status: 1, type: 'note')
                       .joins(:drupal_tag)
                       .where('term_data.name LIKE ?', 'question:%')
                       .order('node_counter.totalcount DESC')
                       .includes(:drupal_node_counter)
                       .group('node.nid')
    sort_question_by_tags
    @questions = @questions.limit(20)

    @wikis = DrupalNode.limit(10)
                       .where(type: 'page', status: 1)
                       .order("nid DESC")
    @unpaginated = true
    render :template => 'questions/index'
  end

  def liked
    @title = "Highly liked Questions"
    @questions = DrupalNode.where(status: 1, type: 'note')
                       .joins(:drupal_tag)
                       .where('term_data.name LIKE ?', 'question:%')
                       .order("cached_likes DESC")
                       .group('node.nid')
    sort_question_by_tags
    @questions = @questions.limit(20)

    @wikis = DrupalNode.limit(10)
                       .where(type: 'page', status: 1)
                       .order("nid DESC")
    @unpaginated = true
    render :template => 'questions/index'
  end
end
