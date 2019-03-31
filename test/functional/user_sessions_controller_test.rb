require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase

  test 'should login an user' do
    post :create, params: { user_session: { username: users(:jeff).username, password: 'secretive' } }
    assert_redirected_to '/dashboard'
  end

  test 'should redirect to create new account if username doesnt exist' do
    post :create, params: { user_session: { username: 'nobody', password: 'blablabla' } }
    assert_redirected_to '/login'
    assert_equal 'There is nobody in our system by that name, are you sure you have the right username?', flash[:warning]
  end

  test 'login user with an email' do
    post :create, params: { user_session: { username: users(:jeff).email, password: 'secretive' } }
    assert_redirected_to '/dashboard'
  end

  test 'should login and redirect to corresct url' do
    session[:return_to] = '/post?tags=question:question&template=question'
    post :create, params: { user_session: { username: users(:jeff).username, password: 'secretive' } }
    assert_redirected_to '/post?tags=question:question&template=question'
  end

  test 'should choose I18n in settings controller, then display correct language login message on log in' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      # set locale in cookie
      get :change_locale, params: { locale: lang.to_s }

      @controller = old_controller

      post :create, params: { user_session: { username: users(:jeff).username, password: 'secretive' } }

      assert_redirected_to '/dashboard'
      assert_equal I18n.t('user_sessions_controller.logged_in'), flash[:notice]
    end
  end

  test 'sign up and login via provider basic flow for google' do
    assert_not_nil OmniAuth.config.mock_auth[:google_oauth2]
    #Omniauth hash is present
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:google_oauth2]
    assert_not_nil request.env['omniauth.auth']
    #Sign Up for a new user
    post :create
    assert_equal "You have successfully signed in. Please change your password using the link sent to you via e-mail.",  flash[:notice]
    #Log Out
    post :destroy
    assert_equal "Successfully logged out.",  flash[:notice]
    #auth hash is present so login via a provider
    post :create
    assert_equal "Signed in!",  flash[:notice]
  end

  test 'sign up and login via provider alternative flow for google' do
    assert_not_nil OmniAuth.config.mock_auth[:google_oauth2_2]
    #Omniauth hash is present
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:google_oauth2_2]
    assert_not_nil request.env['omniauth.auth']
    #Sign Up for an existing user as email exists in the db
    post :create
    assert_equal "Successfully linked to your account!",  flash[:notice]
    #Log Out
    post :destroy
    assert_equal "Successfully logged out.",  flash[:notice]
    #auth hash is present so login via a provider
    post :create
    assert_equal "Signed in!",  flash[:notice]
  end


  test 'login user with an email and then connect google provider' do
    post :create,
       params: {
        user_session: {
        username: users(:jeff).email,
        password: 'secretive'
        }
       }
    assert_redirected_to '/dashboard'
    assert_not_nil OmniAuth.config.mock_auth[:google_oauth2_2]
    #Omniauth hash is present
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:google_oauth2_2]
    assert_not_nil request.env['omniauth.auth']
    #Link a google account to an existing user
    post :create
    assert_equal "Successfully linked to your account!",  flash[:notice]
    #Link same google account to an existing user again
    post :create
    assert_equal "Already linked to your account!",  flash[:notice]
    #Log Out
    post :destroy
    assert_equal "Successfully logged out.",  flash[:notice]
  end

  test 'sign up and login via provider basic flow for github' do
    assert_not_nil OmniAuth.config.mock_auth[:github1]
    #Omniauth hash is present
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:github1]
    assert_not_nil request.env['omniauth.auth']
    #Sign Up for a new user
    post :create
    assert_equal "You have successfully signed in. Please change your password using the link sent to you via e-mail.",  flash[:notice]
    #Log Out
    post :destroy
    assert_equal "Successfully logged out.",  flash[:notice]
    #auth hash is present so login via a provider
    post :create
    assert_equal "Signed in!",  flash[:notice]
  end

  test 'sign up and login via provider alternative flow for github' do
    assert_not_nil OmniAuth.config.mock_auth[:github2]
    #Omniauth hash is present
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:github2]
    assert_not_nil request.env['omniauth.auth']
    #Sign Up for an existing user as email exists in the db
    post :create
    assert_equal "Successfully linked to your account!",  flash[:notice]
    #Log Out
    post :destroy
    assert_equal "Successfully logged out.",  flash[:notice]
    #auth hash is present so login via a provider
    post :create
    assert_equal "Signed in!",  flash[:notice]
  end

  test 'login user with an email and then connect github provider' do
    post :create,
       params: {
        user_session: {
        username: users(:jeff).email,
        password: 'secretive'
        }
       }
    assert_redirected_to '/dashboard'
    assert_not_nil OmniAuth.config.mock_auth[:github2]
    #Omniauth hash is present
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:github2]
    assert_not_nil request.env['omniauth.auth']
    #Link a github account to an existing user
    post :create
    assert_equal "Successfully linked to your account!",  flash[:notice]
    #Link same github account to an existing user again
    post :create
    assert_equal "Already linked to your account!",  flash[:notice]
    #Log Out
    post :destroy
    assert_equal "Successfully logged out.",  flash[:notice]
  end


    test 'sign up and login via provider basic flow for twitter' do
      assert_not_nil OmniAuth.config.mock_auth[:twitter1]
      #Omniauth hash is present
      request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:twitter1]
      assert_not_nil request.env['omniauth.auth']
      #Sign Up for a new user
      post :create
      assert_equal "You have successfully signed in. Please change your password using the link sent to you via e-mail.",  flash[:notice]
      #Log Out
      post :destroy
      assert_equal "Successfully logged out.",  flash[:notice]
      #auth hash is present so login via a provider
      post :create
      assert_equal "Signed in!",  flash[:notice]
    end

    test 'sign up and login via provider alternative flow for twitter' do
      assert_not_nil OmniAuth.config.mock_auth[:twitter2]
      #Omniauth hash is present
      request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:twitter2]
      assert_not_nil request.env['omniauth.auth']
      #Sign Up for an existing user as email exists in the db
      post :create
      assert_equal "Successfully linked to your account!",  flash[:notice]
      #Log Out
      post :destroy
      assert_equal "Successfully logged out.",  flash[:notice]
      #auth hash is present so login via a provider
      post :create
      assert_equal "Signed in!",  flash[:notice]
    end

    test 'login user with an email and then contwitter provider' do
      post :create,
         params: {
          user_session: {
          username: users(:jeff).email,
          password: 'secretive'
          }
         }
      assert_redirected_to '/dashboard'
      assert_not_nil OmniAuth.config.mock_auth[:twitter2]
      #Omniauth hash is present
      request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:twitter2]
      assert_not_nil request.env['omniauth.auth']
      #Link a twitter account to an existing user
      post :create
      assert_equal "Successfully linked to your account!",  flash[:notice]
      #Link same twitter account to an existing user again
      post :create
      assert_equal "Already linked to your account!",  flash[:notice]
      #Log Out
      post :destroy
      assert_equal "Successfully logged out.",  flash[:notice]
  end

  test 'sign up and login via provider basic flow for facebook' do
    assert_not_nil OmniAuth.config.mock_auth[:facebook1]
    #Omniauth hash is present
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:facebook1]
    assert_not_nil request.env['omniauth.auth']
    #Sign Up for a new user
    post :create
    assert_equal "You have successfully signed in. Please change your password using the link sent to you via e-mail.",  flash[:notice]
    #Log Out
    post :destroy
    assert_equal "Successfully logged out.",  flash[:notice]
    #auth hash is present so login via a provider
    post :create
    assert_equal "Signed in!",  flash[:notice]
  end

  test 'sign up and login via provider alternative flow for facebook' do
    assert_not_nil OmniAuth.config.mock_auth[:facebook2]
    #Omniauth hash is present
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:facebook2]
    assert_not_nil request.env['omniauth.auth']
    #Sign Up for an existing user as email exists in the db
    post :create
    assert_equal "Successfully linked to your account!",  flash[:notice]
    #Log Out
    post :destroy
    assert_equal "Successfully logged out.",  flash[:notice]
    #auth hash is present so login via a provider
    post :create
    assert_equal "Signed in!",  flash[:notice]
  end

  test 'login user with an email and then connect facebook provider' do
    post :create,
       params: {
        user_session: {
        username: users(:jeff).email,
        password: 'secretive'
        }
       }
    assert_redirected_to '/dashboard'
    assert_not_nil OmniAuth.config.mock_auth[:facebook2]
    #Omniauth hash is present
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:facebook2]
    assert_not_nil request.env['omniauth.auth']
    #Link a facebook account to an existing user
    post :create
    assert_equal "Successfully linked to your account!",  flash[:notice]
    #Link same facebook account to an existing user again
    post :create
    assert_equal "Already linked to your account!",  flash[:notice]
    #Log Out
    post :destroy
    assert_equal "Successfully logged out.",  flash[:notice]
  end
end
