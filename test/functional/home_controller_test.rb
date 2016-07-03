# def home
# def front
# def dashboard
# def comments
# def nearby

require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  test "should get home" do
    get :home

    assert_response :success
  end

  test "should get dashboard if not logged in" do
    get :dashboard

    assert_response :success
  end

  test "should get dashboard" do
    UserSession.create(rusers(:bob))

    get :dashboard

    assert_response :success
  end
  
  test "should change i18n-locale to English" do
    I18n.locale = 'en'
    assert_equal 'en', "#{I18n.locale}"
    assert true
  end

  test "should change i18n-locale to Deutsch" do
    I18n.locale = 'de'
    assert_equal 'de', "#{I18n.locale}"
    assert true
  end
  
  test "should choose i18n for layout/alerts" do
    available_testing_locales.each do |lang|
      cookies.permanent[:plots2_locale] = lang
      UserSession.create(rusers(:bob))
      session[:openid_return_to] = '/home'
      get :dashboard
      assert_select "a[href=/openid/resume]", I18n.t('layout._alerts.approve_or_deny')+' &raquo;'
      assert true
    end
  end
  
  test "should choose i18n for home/comments" do
    available_testing_locales.each do |lang|
      cookies.permanent[:plots2_locale] = lang
      get 'comments'
      assert_template partial: "home/_comments"
      assert_select 'span', I18n.t('home._comments.commented') + ' :'
      assert true
    end
  end
end
