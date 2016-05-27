require 'test_helper'

class LoginFlowTest < ActionDispatch::IntegrationTest
  test "redirect to login page if user is not logged in and then redirect back to desired page after login" do  	
  	get '/post?tags=question:question&template=question'
  	follow_redirect!
  	assert_equal '/login', path

  	post '/user_sessions', user_session: {
  										username: rusers(:jeff).username,
  										password: 'secret'
  							   	}
  	follow_redirect!
  	assert_equal '/post?tags=question:question&template=question', request.fullpath
  end
end
