require 'test_helper'

class FeaturesControllerTest < ActionController::TestCase

  test "should not get features if not admin" do
    session[:user_id] = rusers(:bob).id # log in; this is not actually working
    get :index
    assert_response :redirect
  end

  # fix log in before this can work:

  #test "should get features if admin" do
  #  session[:user_id] = rusers(:jeff).id # log in
  #  get :index
  #  assert_response :success
  #  assert_not_nil :features
  #end

end
