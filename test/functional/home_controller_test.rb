# def home
# def front
# def dashboard
# def comments
# def nearby

require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  test "should get home" do
    get :home

    assert_response :success
  end

  test "should not get dashboard if not logged in" do
    get :dashboard

    assert_response 302
  end

  test "should get dashboard" do
    UserSession.create(rusers(:bob))

    get :dashboard

    assert_response :success
  end

  test "should get dashboard2" do
    UserSession.create(rusers(:bob))

    get :dashboard2

    assert_response :success
  end

end
