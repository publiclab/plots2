require "application_system_test_case"

class SettingsTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'viewing the settings page' do
    visit '/'

    find(".nav-link.loginToggle").click()


    fill_in("username-login", with: "namangupta")
    fill_in("password-signup", with: "secretive")
    find(".login-modal-form #login-button").click()


    visit '/settings'

    take_screenshot
  end

end
