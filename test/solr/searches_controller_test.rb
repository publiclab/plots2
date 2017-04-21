require 'test_helper'

class SearchesControllerTest < ActionController::TestCase
  tests SearchesController

  def setup
    @normal_search = searches(:normal)
    @advanced_search = searches(:advanced_note)
    activate_authlogic
    @user = rusers(:newcomer)
    UserSession.create(@user)
  end

  def teardown
    UserSession.find.destroy if UserSession.find
  end

  test 'should get search test action' do
    get :test
    assert_not_nil :search
    assert_response :success
    assert_not_nil JSON.parse(@response.body)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get dynamic' do
    get :dynamic
    assert_response :success
  end

  test 'should get show' do
    get :show, id: @advanced_search
    assert_response :success
    assert_equal 'Advanced search', @advanced_search.title
  end

  # initial advanced search page
  test 'should get new' do
    get :new
    assert_response :success
    assert_not_nil :search
    assert_template :new
  end

  test 'should get normal search' do
    get :normal_search, id: 'ujitha'
    assert_response :success
  end

end
