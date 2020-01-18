require "application_system_test_case"

class DashboardTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'viewing the dashboard' do
    visit '/'

    find(".nav-link.loginToggle").click()


    take_screenshot

    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    find(".login-modal-form #login-button").click()


    visit '/dashboard'

    title = find('.row.header h1').text
    activity = find('#activity-header i').text

    assert_equal "Dashboard", title
    assert_equal "Activity", activity

    take_screenshot

  end

end
