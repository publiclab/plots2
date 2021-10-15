require "application_system_test_case"
require "i18n"

class DashboardTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'should translate search input bar' do
    available_testing_locales.each do |lang|
      visit '/'
      visit '/change_locale/'+lang.to_s
      click_on I18n.t('layout._header.login.login_title', locale: lang)
      fill_in("username-login", with: "Bob")
      fill_in("password-signup", with: "secretive")
      click_on I18n.t('user_sessions.new.log_in', locale: lang)
      visit '/v1/dashboard'
      uid = users(:bob).id
      visit '/profile/tags/create/'+uid.to_s+'?translationswitch=yes&name=translation-helper'
      assert_selector(:xpath, './/input[@id="searchform_input"][contains(@placeholder,"Search")]')
      visit '/logout'
    end
  end

  test 'viewing the dashboard' do
    visit '/'

    click_on 'Login'

    take_screenshot

    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"

    visit '/v1/dashboard'

    assert_selector('.row .header h1', text: "Dashboard")
    assert_selector('#activity-header > i', text: "Activity")

    take_screenshot

  end
  
  test "User can flag a node from dashboard" do
    visit '/'
    click_on 'Login'
    node = Node.where(status: 1)
      .order(nid: :desc)
      .first
    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"
    visit 'v1//dashboard'
    find("#flag_node#{node.id}").click()
    assert find("div.alert", text: "Node flagged.")
  end
end
