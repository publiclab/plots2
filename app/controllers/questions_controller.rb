class QuestionsController < ApplicationController

  def index
    @title = "Questions and Answers"
    set_sidebar
    @questions = @notes
    sort_question_by_tags
    @questions = @questions.order('node.nid DESC')
                           .paginate(:page => params[:page], :per_page => 30)
  end
  
  def new
    render "editor/question"
  end

  def show
    if params[:author] && params[:date]
      @node = Node.find_notes(params[:author], params[:date], params[:id])
      @node = @node || Node.where(path: "/report/#{params[:id]}").first
      # if request.path != @node.path(:question)
      #   return redirect_to @node.path(:question), :status => :moved_permanently
      # end
    else
      @node = Node.find params[:id]
    end

    unless @node.has_power_tag('question')
      redirect_to @node.path
    end

    alert_and_redirect_moderated

    impressionist(@node.drupal_node_counter)
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
    @questions = Node.questions.where(status: 1)
    sort_question_by_tags
    @questions = @questions.joins(:answers)
                          .order('answers.created_at DESC')
                          .group('node.nid')
                          .paginate(:page => params[:page], :per_page => 30)

    @wikis = Node.limit(10)
                       .where(type: 'page', status: 1)
                       .order("nid DESC")
    render :template => 'questions/index'
  end

  def unanswered
    @title = "Unanswered questions"
    @questions = Node.questions.where(status: 1)
    sort_question_by_tags
    @questions = @questions.includes(:answers)
                .where( answers: { id: nil } )
                .order('answers.created_at ASC')
                .group('node.nid')
                .paginate(:page => params[:page], :per_page => 30)
    render :template => 'questions/index'
  end
  
  def shortlink
    @node = Node.find params[:id]
    if @node.has_power_tag('question')
      redirect_to @node.path(:question)
    else
      redirect_to @node.path
    end
  end

  def popular
    @title = "Popular Questions"
    @questions = Node.questions.where(status: 1)
    sort_question_by_tags
    @questions = @questions.order('node_counter.totalcount DESC')
                           .includes(:drupal_node_counter)
                           .limit(20)

    @wikis = Node.limit(10)
                       .where(type: 'page', status: 1)
                       .order("nid DESC")
    @unpaginated = true
    render :template => 'questions/index'
  end

  def liked
    @title = "Highly liked Questions"
    @questions = Node.questions.where(status: 1)
    sort_question_by_tags
    @questions = @questions.order("cached_likes DESC")
                           .limit(20)

    @wikis = Node.limit(10)
                       .where(type: 'page', status: 1)
                       .order("nid DESC")
    @unpaginated = true
    render :template => 'questions/index'
  end
end
