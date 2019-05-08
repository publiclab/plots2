require "application_system_test_case"

class DashboardTest < ApplicationSystemTestCase

  test 'viewing the dashboard' do
    visit '/'

    click_on 'Login'

    take_screenshot

    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"

    visit '/dashboard'

    assert_selector('.row.header > h1', text: "Dashboard")
    assert_selector('#activity-header > i', text: "Activity")

    take_screenshot

  end

end
