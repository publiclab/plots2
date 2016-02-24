require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  test "should get home" do
    get :home
    assert_response :success
  end

  test "should not get dashboard if not logged in" do
    get :dashboard
    assert_response 302
  end

#  test "should get dashboard" do
#    UserSession.create(@user)
#    get :dashboard
#    assert_response :success
#  end

end
