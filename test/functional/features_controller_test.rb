require 'test_helper'

class FeaturesControllerTest < ActionController::TestCase

  fixtures :rusers
  set_fixture_class :rusers => User

  test "should not get features if not admin" do
    session[:user_id] = rusers(:bob).id # log in
    get :index
    assert_response :302
  end

  test "should get features if admin" do
    session[:user_id] = rusers(:jeff).id # log in
    get :index
    assert_response :success
    assert_not_nil :features
  end

end
