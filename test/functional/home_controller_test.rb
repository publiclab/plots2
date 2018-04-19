require 'test_helper'
require 'sanitize'

class HomeControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
  end

  test 'should get home' do
    title = I18n.t('home_controller.science_community')

    get :home
    assert_response :success
    assert_select "title", Sanitize.clean('&#127880;') + (" Public Lab: #{title}")
  end

  test 'home should redirect to dashboard if logged in' do
    UserSession.create(users(:bob))

    get :home
    assert_redirected_to dashboard_url
  end

  test 'should get research if not logged by /dashboard' do
    get :dashboard
    assert_redirected_to :research
    get :research
    assert_response :success
  end

  test 'should get research if not logged' do
    get :research
    assert_response :success
  end

  test 'should get dashboard if logged in by /research' do
    UserSession.create(users(:bob))
    get :research
    assert_redirected_to :dashboard
    get :dashboard
    assert_response :success
  end

  test 'should get dashboard if logged in' do
    UserSession.create(users(:bob))
    get :dashboard
    assert_response :success
    assert_select 'a[href=?]', "mailto:moderators@publiclab.org?subject=Reporting+spam+on+Public+Lab&body=Hi,+I+found+this+item+that+looks+like+spam+or+needs+to+be+moderated:+Canon+A1200+IR+conversion+at+PLOTS+Barnraising+at+LUMCON+https://publiclab.org/n/1+by+https://publiclab.org/profile/jeff+Thanks!"
  end

  test 'should show only unmoderated spam' do
    @wikis = Node.where(type: 'page')
    revisions = Revision.joins(:node)
                        .where('type = (?)', 'page')
                        .where('node_revisions.status = 1')
    @wikis += revisions

    get :research

    @wikis.each do |obj|
      if obj.class == Revision && obj.status == 1
        selections = css_select '.wiki'
        assert_equal selections.length, 6
      elsif obj.class == Revision && obj.status != 1
        selections = css_select '.wiki'
        assert_equal selections.length, 0
      end
    end
  end

  test 'should change i18n-locale to English' do
    I18n.locale = 'en'
    assert_equal 'en', I18n.locale.to_s
  end

  test 'should change i18n-locale to Deutsch' do
    I18n.locale = 'de'
    assert_equal 'de', I18n.locale.to_s
  end

  test 'should choose i18n for layout/alerts' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      get :change_locale, locale: lang.to_s

      @controller = old_controller

      UserSession.create(users(:bob))
      session[:openid_return_to] = '/home'
      get :dashboard
      assert_select 'a[href=?]', "/openid/resume", I18n.t('layout._alerts.approve_or_deny') + Sanitize.clean(' &raquo;')
      assert true
    end
  end

  test 'should choose i18n for home/home' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      get :change_locale, locale: lang.to_s

      @controller = old_controller

      get 'home'
      assert_template 'home/home'
      assert_select 'h2', I18n.t('home.home.the_problem.title')
    end
  end
end
