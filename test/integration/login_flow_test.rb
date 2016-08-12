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

  # This test depend on question based search functionality
  test "search a question and go through post mechanism if question not found when user is not logged in" do
    get '/questions_search/What'
    follow_redirect!
    assert_equal '/post?tags=question:question&template=question&title=What&redirect=question', request.fullpath

    follow_redirect!
    assert_equal '/login', path

    post '/user_sessions', user_session: {
      username: rusers(:jeff).username,
      password: 'secret'
    }
    follow_redirect!
    assert_equal '/post?tags=question:question&template=question&title=What&redirect=question', request.fullpath
    assert_select "input#title" do
      assert_select "[value=?]", "What"
    end
  end

  test "should redirect to current page when logging in through the header login" do
    get '/questions'
    assert_response :success

    post '/user_sessions',
         return_to: request.path,
         user_session: {
           username: rusers(:jeff).username,
           password: 'secret'
         }
    follow_redirect!
    assert_equal '/questions', path
  end
end
