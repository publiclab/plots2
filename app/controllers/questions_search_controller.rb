class QuestionsSearchController < ApplicationController

  # This is a temporary controller for implementing question based search functionality
  # To be removed or modified accordingly by Advanced Search Project
  def index
    @title = "Search questions"
    @tagnames = params[:id].split(',')
    @users = DrupalUsers.where('name LIKE ? AND access != 0', "%"+params[:id]+"%")
                        .order("uid")
                        .limit(5)

    set_sidebar :tags, @tagnames
    @questions = DrupalNode.questions
                           .where('node.status = 1 AND title LIKE ?', "%" + params[:id] + "%")
                           .order('node.nid DESC')
                           .page(params[:page])
    
    render :template => 'searches/normal_search'
  end

  def typeahead
    matches = []
    questions = DrupalNode.where(
                  'type = "note" AND node.status = 1 AND title LIKE ?',
                  "%" + params[:id] + "%"
                )
                  .joins(:drupal_tag)
                  .where('term_data.name LIKE ?', 'question:%')
                  .order('node.nid DESC')
                  .limit(25)
    questions.each do |match|
      link = "<i data-url='" + match.path(:question) + 
             "' class='fa fa-question-circle'></i> " + match.title
      author = "<span class='pull-right'><i class='fa fa-user'></i> " + match.author.name
      likes = " | <i class='fa fa-star'></i> " + match.cached_likes.to_s
      answers = " | <i class='fa fa-comments'></i> " + match.answers.length.to_s + "</span>"
      matches << link + author + likes + answers
    end
    render :json => matches
  end
end
