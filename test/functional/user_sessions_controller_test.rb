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

  test 'should login and redirect to correct url' do
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
    assert_equal "Successfully logged in.",  flash[:notice]
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
    assert_equal "Successfully logged in.",  flash[:notice]
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
    assert_equal "Successfully logged in.",  flash[:notice]
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
    assert_equal "Successfully logged in.",  flash[:notice]
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
    assert_equal "Successfully logged in.",  flash[:notice]
  end

  test 'sign up and login via provider basic flow for twitter user with no email' do
    assert_not_nil OmniAuth.config.mock_auth[:twitter_no_email]
    #Omniauth hash is present
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:twitter_no_email]
    assert_not_nil request.env['omniauth.auth']
    #Sign Up for a new user
    assert_nil session[:user_session]
    assert_difference 'User.count', 0 do
      post :create
    end
    assert_nil session[:user_session]
    assert_equal "You have tried using a Twitter account with no associated email address. Unfortunately we need an email address; please add one and try again, or sign up a different way. Thank you!",  flash[:error]
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
    assert_equal "Successfully logged in.",  flash[:notice]
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
    assert_equal "Successfully logged in.",  flash[:notice]
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
    assert_equal "Successfully logged in.",  flash[:notice]
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
  
  test "logging in with banned user through oauth should fail and redirect correctly" do
    request.env['omniauth.origin'] = "/notes/liked"
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:github1]
    post :create
    post :destroy
    # name of omniauth user
    User.find_by(name: "bansal_sidharth309").ban
    post :create
    assert @response.redirect_url.include? "/notes/liked"
    assert_equal flash[:error], I18n.t('user_sessions_controller.user_has_been_banned', username: "bansal_sidharth309").html_safe
  end
  
  test "logging in with moderated user through oauth should fail and redirect correctly" do
    request.env['omniauth.origin'] = "/notes/liked"
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:github1]
    post :create
    post :destroy
    User.find_by(name: "bansal_sidharth309").moderate
    post :create
    assert @response.redirect_url.include? "/notes/liked"
    assert_equal flash[:error], I18n.t('user_sessions_controller.user_has_been_moderated', username: "bansal_sidharth309").html_safe
  end
  
  test "redirects dashboard on signup with oauth and redirects to previous page when logging in" do
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:github1]
    post :create
    assert_equal "You have successfully signed in. Please change your password using the link sent to you via e-mail.", flash[:notice]
    assert_redirected_to "/dashboard"
    post :destroy
    assert_equal I18n.t('user_sessions_controller.logged_out'), flash[:notice]
    request.env['omniauth.origin'] = "/notes/liked"
    post :create
    assert_equal I18n.t('user_sessions_controller.logged_in'), flash[:notice]
    assert @response.redirect_url.include? "/notes/liked"
  end
  
  test "logging in through omniauth and then logging in with username should display correct error and redirect" do
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:github1]
    # login through omniauth 
    post :create
    # logout
    post :destroy
    request.env['omniauth.auth'] = nil
    post :create, params: { user_session: { username: "bansal_sidharth309", password: "random"} }
    assert_equal flash[:error], "This account doesn't have a password set. It may be logged in with Github account, or you can set a new password via Forget password feature"
  end
  
  test "logging in through omniauth and then logging in with email should display correct error and redirect" do
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:github1]
    # login through omniauth 
    post :create
    # logout
    post :destroy
    request.env['omniauth.auth'] = nil
    post :create, params: { user_session: { username: "bansal.sidharth309@gmail.com", password: "random"} }
    assert_equal flash[:error], "This account doesn't have a password set. It may be logged in with Github account, or you can set a new password via Forget password feature"
  end
  
  test "logging in with banned user through normal login should fail" do
    user = users(:bob)
    user.ban
    post :create, params: { user_session: { username: user.username, password: 'secretive' } }
    assert_redirected_to root_url
    assert_equal flash[:error], I18n.t('user_sessions_controller.user_has_been_banned', username: user.username).html_safe
  end
  
  test "logging in with moderated user through normal login should fail" do
    user = users(:bob)
    user.moderate
    post :create, params: { user_session: { username: user.username, password: 'secretive' } }
    assert_redirected_to root_url
    assert_equal flash[:error], I18n.t('user_sessions_controller.user_has_been_moderated', username: user.username).html_safe
  end
  test "user that links provider to existing account should not be redirected to dashboard on oauth signup for Github provider" do
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:github4]
    request.env['omniauth.origin'] = "/notes/liked"
    post :create
    assert @response.redirect_url.include? "/notes/liked"
    assert_equal "Successfully linked to your account!", flash[:notice]
  end

  test "user that links provider to existing account should not be redirected to dashboard on oauth signup for Google provider" do
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:google_oauth2_4]
    request.env['omniauth.origin'] = "/notes/liked"
    post :create
    assert @response.redirect_url.include? "/notes/liked"
    assert_equal "Successfully linked to your account!", flash[:notice]
  end

  test "user that links provider to existing account should not be redirected to dashboard on oauth signup for Facebook provider" do
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:facebook4]
    request.env['omniauth.origin'] = "/notes/liked"
    post :create
    assert @response.redirect_url.include? "/notes/liked"
    assert_equal "Successfully linked to your account!", flash[:notice]
  end

  test "user that links provider to existing account should not be redirected to dashboard on oauth signup for Twitter provider" do
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:twitter4]
    request.env['omniauth.origin'] = "/notes/liked"
    post :create
    assert @response.redirect_url.include? "/notes/liked"
    assert_equal "Successfully linked to your account!", flash[:notice]
  end
end
