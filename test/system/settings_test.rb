require "application_system_test_case"

class SettingsTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'viewing the settings page' do
    visit '/'

    click_on 'Login'

    fill_in("username-login", with: "namangupta")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"

    visit '/settings'

    take_screenshot
  end

end

