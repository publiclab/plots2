require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  test "should login an user" do
    post :create, user_session: {
      username: rusers(:jeff).username,
      password: 'secret'
    }
    assert_redirected_to '/dashboard'
  end

test "login user with an email" do 
  post :create, user_session: 
  {
    username: rusers(:jeff).email , 
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
  
  test "should choose I18n for user sessions controller" do
    available_testing_locales.each do |lang|
        old_controller = @controller
        @controller = SettingsController.new
        
        get :change_locale, :locale => lang.to_s
        
        @controller = old_controller
        
        post :create, user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        assert_equal I18n.t('user_sessions_controller.logged_in'), flash[:notice]
    end
  end
end
