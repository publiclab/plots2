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
end
