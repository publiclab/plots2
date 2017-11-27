require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase

  test 'should login an user' do
    post :create, user_session: {
      username: users(:jeff).username,
      password: 'secretive'
    }
    assert_redirected_to '/dashboard'
  end

  test 'login user with an email' do
    post :create, user_session: {
      username: users(:jeff).email,
      password: 'secretive'
    }
    assert_redirected_to '/dashboard'
  end

  test 'should login and redirect to corresct url' do
    session[:return_to] = '/post?tags=question:question&template=question'
    post :create, user_session: {
      username: users(:jeff).username,
      password: 'secretive'
    }
    assert_redirected_to '/post?tags=question:question&template=question'
  end

  test 'should choose I18n in settings controller, then display correct language login message on log in' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      # set locale in cookie
      get :change_locale, locale: lang.to_s

      @controller = old_controller

      post :create, user_session: {
        username: users(:jeff).username,
        password: 'secretive'
      }

      assert_redirected_to '/dashboard'
      assert_equal I18n.t('user_sessions_controller.logged_in'), flash[:notice]
    end
  end

end
