require 'test_helper'

class SearchesControllerTest < ActionController::TestCase
  tests SearchesController

  def setup
    @normal_search = searches(:normal)
    @advanced_search = searches(:advanced_note)
    @user = users(:newcomer)
    activate_authlogic
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

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create new search' do
    assert_difference('Search.count') do
      post :create, search: {
        title: 'advanced search',
        user_id: @user.id,
        main_type: 'Notes or Wiki updates',
        key_words: 'blog'
      }
    end
    assert_equal 'Advanced search', assigns(:search).title
    assert_equal @user.id, assigns(:search).user_id
    assert_equal 'Notes or Wiki updates', assigns(:search).main_type
    assert_equal 'blog', assigns(:search).key_words
    assert_redirected_to search_path(assigns(:search))
  end

  test 'should get normal search' do
    get :normal_search, id: 'ujitha'
    assert_response :success
  end

  test 'should update advanced search' do
    put :update, id: @advanced_search, search: {
      key_words: 'Ujitha',
      main_type: 'User Profiles'
    }
    assert_equal 'Advanced search', assigns(:search).title
    assert_equal '2', assigns(:search).user_id
    assert_equal 'User Profiles', assigns(:search).main_type
    assert_equal 'Ujitha', assigns(:search).key_words
    assert_redirected_to search_path(assigns(:search))
  end

end
