class QuestionsController < ApplicationController
  private

  def filter_questions_by_tag(questions, tagnames)
    tagnames ||= ''
    tagnames = tagnames.split(',')
    nids = questions.collect(&:nid)
    questions = Node.where(status: 1, type: 'note')
                    .joins(:tag)
                    .where('node.nid IN (?)', nids)
                    .group('node.nid')
    if !tagnames.empty?
      questions.where('term_data.name IN (?)', tagnames)
    else
      questions
    end
  end

  public

  def index
    @title = 'Questions and Answers'
    set_sidebar
    @questions = Node.questions
                     .where(status: 1)
                     .order('node.nid DESC')
                     .paginate(page: params[:page], per_page: 24)
  end

  def new
    if params[:legacy]
      render 'editor/question'
    else 
      render 'editor/questionRich'
    end
  end

  def show
    if params[:author] && params[:date]
      @node = Node.find_notes(params[:author], params[:date], params[:id])
      @node ||= Node.where(path: "/report/#{params[:id]}").first
    else
      @node = Node.find params[:id]
    end

    redirect_to @node.path unless @node.has_power_tag('question')

    alert_and_redirect_moderated

    impressionist(@node)
    @title = @node.latest.title
    @tags = @node.power_tag_objects('question')
    @tagnames = @tags.collect(&:name)
    @users = @node.answers.group(:uid)
                  .order('count(*) DESC')
                  .collect(&:author)

    set_sidebar :tags, @tagnames
  end

  def answered
    @title = 'Recently answered'
    @questions = Node.questions
                     .where(status: 1)
    @questions = filter_questions_by_tag(@questions, params[:tagnames])
                 .joins(:answers)
                 .order('answers.created_at DESC')
                 .group('node.nid')
                 .paginate(page: params[:page], per_page: 24)
    @wikis = Node.limit(10)
                 .where(type: 'page', status: 1)
                 .order('nid DESC')
    render template: 'questions/index'
  end

  def unanswered
    @title = 'Unanswered questions'
    @questions = Node.questions
                     .where(status: 1)
                     .includes(:answers)
                     .where(answers: { id: nil })
                     .order('answers.created_at ASC')
                     .group('node.nid')
                     .paginate(page: params[:page], per_page: 24)
    render template: 'questions/index'
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
    @title = 'Popular Questions'
    @questions = Node.questions
                     .where(status: 1)
    @questions = filter_questions_by_tag(@questions, params[:tagnames])
                 .order('views DESC')
                 .limit(20)

    @wikis = Node.limit(10)
                 .where(type: 'page', status: 1)
                 .order('nid DESC')
    @unpaginated = true
    render template: 'questions/index'
  end

  def liked
    @title = 'Highly liked Questions'
    @questions = Node.questions.where(status: 1)
    @questions = filter_questions_by_tag(@questions, params[:tagnames])
                 .order('cached_likes DESC')
                 .limit(20)

    @wikis = Node.limit(10)
                 .where(type: 'page', status: 1)
                 .order('nid DESC')
    @unpaginated = true
    render template: 'questions/index'
  end
end
