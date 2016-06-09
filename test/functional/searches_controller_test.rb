require 'test_helper'

class SearchesControllerTest < ActionController::TestCase
  tests SearchesController

  def setup
    @normal_search = searches(:normal)
    @advanced_search = searches(:advanced)
    activate_authlogic
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get show' do
    get :show, id: @advanced_search
    assert_response :success
    assert_equal 'Advanced search', @advanced_search.title
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create new search' do
    assert_difference('Search.count') do
      post :create, search: {
        title: 'advanced search',
      }
    end
    assert_equal 'Advanced search', assigns(:search).title
    assert_redirected_to search_path(assigns(:search))
  end

end
