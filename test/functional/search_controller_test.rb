require 'test_helper'

class SearchControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  test "get search/index" do
    get :index, id: 'test'
    assert_response :success
    assert_not_nil :title
    assert_not_nil :tagnames
    assert_not_nil :users
    assert_not_nil :notes
  end

  test "get search/advanced" do
    get :advanced, id: 'test'
    assert_response :success
    assert_not_nil :nodes
  end

  test "get search/typeahead" do
    get :typeahead, id: 'test'
    assert_response :success
  end

  test "should get search/questions and render template if question match found" do
    get :questions, id: 'How to'
    assert_response :success
    assert_not_nil :title
    assert_not_nil :tagnames
    assert_not_nil :users
    assert_not_nil :notes
    assert_template :index
  end

  test "should redirect to post form if no question match found" do
    UserSession.create(rusers(:bob))
    get :questions, id: 'What'
    assert_empty assigns(:notes)
    assert_redirected_to '/post?tags=question:question&template=question&title=What&redirect=question'
  end

  test "get search/questions_typehead" do
    get :questions_typeahead, id:'How to'
    assert_response :success
  end

  test "get search/map" do
    get :map
    assert_response :success
  end

end
