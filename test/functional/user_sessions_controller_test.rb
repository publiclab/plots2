require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  test "should login an user" do
    post :create, user_session: {
      username: rusers(:jeff).username,
      password: 'secret'
    }
    assert_redirected_to '/dashboard'
  end

  test "should login and redirect to corresct url" do
    session[:return_to] = '/post?tags=question:question&template=question'
    post :create, user_session: {
      username: rusers(:jeff).username,
      password: 'secret'
    }
    assert_redirected_to '/post?tags=question:question&template=question'
  end
end
