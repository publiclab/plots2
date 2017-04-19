require 'test_helper'

class QuestionsSearchControllerTest < ActionController::TestCase
  # These are tests are based on the question based search functionality
  # To be removed or modified accordingly by Advanced Search Project
  def setup
    activate_authlogic
  end

  test 'should get questions_search and render template if question match found' do
    get :index, id: 'How to'
    assert_response :success
    assert_not_nil :title
    assert_not_nil :tagnames
    assert_not_nil :users
    assert_not_nil :questions
    assert_template :normal_search
  end

  test 'questions instance should be empty if no question match found' do
    UserSession.create(rusers(:bob))
    get :index, id: 'What'
    assert_response :redirect
    assert_empty assigns(:notes)
  end

  test 'get search/questions_typehead' do
    get :typeahead, id: 'How to'
    assert_response :success
  end
end
