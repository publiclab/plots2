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
      @node = DrupalNode.where(path: "/notes/#{params[:author]}/#{params[:date]}/#{params[:id]}").first
      @node = @node || DrupalNode.where(path: "/report/#{params[:id]}").first
    else
      @node = DrupalNode.find params[:id]
    end

    unless @node.has_power_tag('question')
      flash[:error] = "Not a question"
      redirect_to "/"
    end

    if @node.author.status == 0 && !(current_user && (current_user.role == "admin" || current_user.role == "moderator"))
      flash[:error] = "The author of that note has been banned."
      redirect_to "/"
    elsif @node.status == 4 && (current_user && (current_user.role == "admin" || current_user.role == "moderator"))
      flash[:warning] = "First-time poster <a href='#{@node.author.name}'>#{@node.author.name}</a> submitted this #{time_ago_in_words(@node.created_at)} ago and it has not yet been approved by a moderator. <a class='btn btn-default btn-sm' href='/moderate/publish/#{@node.id}'>Approve</a> <a class='btn btn-default btn-sm' href='/moderate/spam/#{@node.id}'>Spam</a>"
    elsif @node.status == 4 && (current_user && current_user.id == @node.author.id) && !flash[:first_time_post]
      flash[:warning] = "Thank you for contributing open research, and thanks for your patience while your post is approved by <a href='/wiki/moderation'>community moderators</a> and we'll email you when it is published. In the meantime, if you have more to contribute, feel free to do so."
    elsif @node.status != 1 && !(current_user && (current_user.role == "admin" || current_user.role == "moderator"))
      # if it's spam or a draft
      # no notification; don't let people easily fish for existing draft titles; we should try to 404 it
      redirect_to "/"
    end

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
