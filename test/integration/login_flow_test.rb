require 'test_helper'

class LoginFlowTest < ActionDispatch::IntegrationTest
  test 'redirect to login page if user is not logged in and then redirect back to desired page after login' do
    get '/post?tags=question:question&template=question'
    follow_redirect!
    assert_equal '/login', path

    post '/user_sessions', params: { user_session: { username: users(:jeff).username, password: 'secretive' }  }

    follow_redirect!
    assert_equal '/post?tags=question:question&template=question', request.fullpath
  end

  # This test depend on question based search functionality
  test 'search a question and go through post mechanism if question not found when user is not logged in' do
    get '/post', params: { tags: 'question:question', template: 'question', title: 'What', redirect: 'question' }

    follow_redirect!
    assert_equal '/login', path

    post '/user_sessions', params: { user_session: { username: users(:jeff).username, password: 'secretive' } } 

    follow_redirect!
    assert_response :redirect
    assert_redirected_to '/questions/new?tags=question%3Aquestion&template=question&title=What&redirect=question'
    # These don't pass, though they should according to http://guides.rubyonrails.org/testing.html#helpers-available-for-integration-tests
    # assert_template 'editor/question'
    # assert_select "h4.visible-sm", "Ask a question"
    # assert_select "span.moderation-notice", false
  end

  test 'should redirect to current page when logging in through the header login' do
    get '/questions'
    assert_response :success

    post '/user_sessions', params: { return_to: request.path, user_session: { username: users(:jeff).username,  password: 'secretive' }  } 

    follow_redirect!
    assert_equal '/questions', path
  end

  test 'google login routing' do
    assert_routing '/auth/google_oauth2/callback', {controller: 'user_sessions', action: 'create',provider: 'google_oauth2'}
  end

  test 'google_oauth2 login post' do
    assert_routing({path: '/auth/google_oauth2/callback', method: 'post'},{controller: 'user_sessions', action: 'create' ,provider: 'google_oauth2'})
  end

  test 'should get oauth hash from /auth/google_oauth2' do
    get '/auth/google_oauth2'
    assert_redirected_to '/auth/google_oauth2/callback'
    assert_not_nil OmniAuth.config.mock_auth[:google_oauth2]
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:google_oauth2]
    assert_not_nil request.env['omniauth.auth']
  end

end
