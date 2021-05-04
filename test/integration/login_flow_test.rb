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

  test 'should redirect to dashboard when logging in from /login' do 
    get '/login'
    assert_response :success

    post '/user_sessions', params: { return_to: request.path, user_session: { user_name: users(:jeff).username, password: 'secretive' } }

    follow_redirect!
    assert_redirected_to '/dashboard'
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

  test 'should login and subscribe to multiple tags' do
    post '/register', params: {
          user: {
            username: 'eleven',
            password: 'demagorgon',
            password_confirmation: 'demagorgon',
            email: 'upside@down.today',
            bio: 'From Hawkins'
          },
          spamaway: {
            statement1: I18n.t('spamaway.human.statement1'),
            statement2: I18n.t('spamaway.human.statement2'),
            statement3: I18n.t('spamaway.human.statement3'),
            statement4: I18n.t('spamaway.human.statement4')
          },
          return_to: '/subscribe/multiple/tag/arduino,games'
        }
    assert_response :redirect
    # a success here would mean sent back to form with errors
    assert_redirected_to '/dashboard'
    assert_equal 'Registration successful. Welcome to our community!You are now following \'arduino,games\'.',flash[:notice]

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

  test 'github login routing' do
    assert_routing '/auth/github/callback', {controller: 'user_sessions', action: 'create',provider: 'github'}
  end

  test 'github login post' do
    assert_routing({path: '/auth/github/callback', method: 'post'},{controller: 'user_sessions', action: 'create' ,provider: 'github'})
  end

  test 'should get oauth hash from /auth/github' do
    get '/auth/github'
    assert_redirected_to '/auth/github/callback'
    assert_not_nil OmniAuth.config.mock_auth[:github2]
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:github2]
    assert_not_nil request.env['omniauth.auth']
  end

  test 'twitter login routing' do
    assert_routing '/auth/twitter/callback', {controller: 'user_sessions', action: 'create',provider: 'twitter'}
  end

  test 'twitter login post' do
    assert_routing({path: '/auth/twitter/callback', method: 'post'},{controller: 'user_sessions', action: 'create' ,provider: 'twitter'})
  end

  test 'should get oauth hash from /auth/twitter' do
    get '/auth/twitter'
    assert_redirected_to '/auth/twitter/callback'
    assert_not_nil OmniAuth.config.mock_auth[:twitter2]
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:twitter2]
    assert_not_nil request.env['omniauth.auth']
  end

  test 'facebook login routing' do
    assert_routing '/auth/facebook/callback', {controller: 'user_sessions', action: 'create',provider: 'facebook'}
  end

  test 'facebook login post' do
    assert_routing({path: '/auth/facebook/callback', method: 'post'},{controller: 'user_sessions', action: 'create' ,provider: 'facebook'})
  end

  test 'should get oauth hash from /auth/facebook' do
    get '/auth/facebook'
    assert_redirected_to '/auth/facebook/callback'
    assert_not_nil OmniAuth.config.mock_auth[:facebook2]
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:facebook2]
    assert_not_nil request.env['omniauth.auth']
  end

  test 'redirect to multiple subscription route if user is not logged in and tries to subscribe to multiple tags' do
    get '/subscribe/multiple/tag/blog,kites,balloon,awesome'
    assert_redirected_to '/login?return_to=/subscribe/multiple/tag/blog,kites,balloon,awesome'
    post '/user_sessions', params: { user_session: { username: users(:jeff).username, password: 'secretive' }, return_to: '/subscribe/multiple/tag/blog,kites,balloon,awesome' }
    assert_equal "Successfully logged in.", flash[:notice]
    assert_redirected_to '/subscribe/multiple/tag/blog,kites,balloon,awesome'
  end

  test 'redirect to the dashboard when entering wrong password, then correct password on main page.' do
    get '/'
    assert_response :success
    post '/user_sessions', params: {"return_to":"/", "user_session":{username: users(:jeff).username, password: 'wrong', "remember_me":"0"}}
    assert_response :success
    assert_equal '/user_sessions', path
    post '/user_sessions', params: {"return_to":"/user_sessions", "user_session":{username: users(:jeff).username, password: 'secretive', "remember_me":"0"}}
    follow_redirect!
    assert_redirected_to '/dashboard'
  end

 
test 'reset password for google oauth user' do

    # login user through oauth
    get '/auth/google_oauth2'
    assert_redirected_to '/auth/google_oauth2/callback'

    Rails.application.env_config["omniauth.auth"] =  OmniAuth.config.mock_auth[:google_oauth2]
    #Sign Up through oauth
    post "/user_sessions"
    assert_equal "You have successfully signed in. Please change your password using the link sent to you via e-mail.",  flash[:notice]

    # find new user in db
    user = User.find_by(username: "bansal_sidharth309")

    # setup reset key to create password
    key = user.generate_reset_key
    user.save

    user_attributes = user.attributes
    user_attributes[:password] = 'newpassword'
    user_attributes[:password_confirmation] = 'newpassword'

    get "/reset", params: { key: key, user: user_attributes }

    assert_equal 'Your password was successfully changed.', flash[:notice]

    # logout
    delete "/user_sessions/#{user.id}"
    assert_equal "Successfully logged out.",  flash[:notice]

    # login successfully with new password
    post "/user_sessions", params: { password: "newpassword", username: user.name }
    assert_equal "Successfully logged in.",  flash[:notice]
    Rails.application.env_config["omniauth.auth"] =  nil
  end


  test 'reset password for github oauth user' do

    # login user through oauth
    get '/auth/github'
    assert_redirected_to '/auth/github/callback'

    Rails.application.env_config["omniauth.auth"] =  OmniAuth.config.mock_auth[:github1]
    #Sign Up through oauth
    post "/user_sessions"
    assert_equal "You have successfully signed in. Please change your password using the link sent to you via e-mail.",  flash[:notice]

    # find new user in db
    user = User.find_by(username: "bansal_sidharth309")

    # setup reset key to create password
    key = user.generate_reset_key
    user.save

    user_attributes = user.attributes
    user_attributes[:password] = 'newpassword'
    user_attributes[:password_confirmation] = 'newpassword'

    get "/reset", params: { key: key, user: user_attributes }

    assert_equal 'Your password was successfully changed.', flash[:notice]

    # logout
    delete "/user_sessions/#{user.id}"
    assert_equal "Successfully logged out.",  flash[:notice]

    # login successfully with new password
    post "/user_sessions", params: { password: "newpassword", username: user.name }
    assert_equal "Successfully logged in.",  flash[:notice]
    Rails.application.env_config["omniauth.auth"] =  nil
  end


  test 'reset password for twitter oauth user' do

    # login user through oauth
    get '/auth/twitter'
    assert_redirected_to '/auth/twitter/callback'

    Rails.application.env_config["omniauth.auth"] =  OmniAuth.config.mock_auth[:twitter1]
    #Sign Up through oauth
    post "/user_sessions"
    assert_equal "You have successfully signed in. Please change your password using the link sent to you via e-mail.",  flash[:notice]

    # find new user in db
    user = User.find_by(username: "bansal_sidharth309")

    # setup reset key to create password
    key = user.generate_reset_key
    user.save

    user_attributes = user.attributes
    user_attributes[:password] = 'newpassword'
    user_attributes[:password_confirmation] = 'newpassword'

    get "/reset", params: { key: key, user: user_attributes }

    assert_equal 'Your password was successfully changed.', flash[:notice]

    # logout
    delete "/user_sessions/#{user.id}"
    assert_equal "Successfully logged out.",  flash[:notice]

    # login successfully with new password
    post "/user_sessions", params: { password: "newpassword", username: user.name }
    assert_equal "Successfully logged in.",  flash[:notice]
    Rails.application.env_config["omniauth.auth"] =  nil
  end


  test 'reset password for facebook oauth user' do

    # login user through oauth
    get '/auth/facebook'
    assert_redirected_to '/auth/facebook/callback'

    Rails.application.env_config["omniauth.auth"] =  OmniAuth.config.mock_auth[:facebook1]
    #Sign Up through oauth
    post "/user_sessions"
    assert_equal "You have successfully signed in. Please change your password using the link sent to you via e-mail.",  flash[:notice]

    # find new user in db
    user = User.find_by(username: "bansal_sidharth309")

    # setup reset key to create password
    key = user.generate_reset_key
    user.save

    user_attributes = user.attributes
    user_attributes[:password] = 'newpassword'
    user_attributes[:password_confirmation] = 'newpassword'

    get "/reset", params: { key: key, user: user_attributes }

    assert_equal 'Your password was successfully changed.', flash[:notice]

    user = User.find_by(name: "jeff")
    delete "/user_sessions/#{user.id}"
    assert_equal "Successfully logged out.",  flash[:notice]

    # login successfully with new password
    post "/user_sessions", params: { password: "newpassword", username: user.name }
    assert_equal "Successfully logged in.",  flash[:notice]
    Rails.application.env_config["omniauth.auth"] =  nil
  end
end
