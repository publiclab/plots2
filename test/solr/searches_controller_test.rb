require 'test_helper'

class SearchesControllerTest < ActionController::TestCase
  tests SearchesController

  def setup
    activate_authlogic
    @user = users(:newcomer)
    UserSession.create(@user)
  end

  def teardown
    UserSession.find.destroy if UserSession.find
  end

  test 'should get search test action' do
    get :test
    assert_not_nil :search
    assert_response :success
    assert_not_nil @response.body
    result = JSON.parse(@response.body)
    assert_not_nil result
    assert_not_equal result, []
  end

  test 'should get dynamic' do
    get :dynamic
    assert_response :success
  end

  test 'should get results' do
    get :results, id: 'Chicago'
    assert_response :success
  end

end
