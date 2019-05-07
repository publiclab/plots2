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
    assert_selector('.page-item.active > .page-link', text: "1")
    assert_selector('.page-item:nth-child(2) > .page-link', text: "2")

    take_screenshot

  end

end
