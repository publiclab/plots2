require "application_system_test_case"

class DashboardTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'viewing the dashboard' do
    visit '/'

    find(".nav-link.loginToggle", match: :first).click()


    take_screenshot

    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    find(".login-modal-form #login-button", match: :first).click()


    visit '/dashboard'

    assert_selector('.row .header h1', text: "Dashboard")
    assert_selector('#activity-header > i', text: "Activity")

    take_screenshot

  end

end
