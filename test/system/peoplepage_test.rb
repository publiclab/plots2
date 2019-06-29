require "application_system_test_case"

class PeoplepageTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 180

  test 'LBLD grid is loaded on people map' do
    visit '/'

    click_on 'Login'

    take_screenshot

    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"

    visit '/people'

    # presence of markers
    assert page.has_selector?(".leaflet-marker-icon")
    # presence of grid
    assert page.has_selector?(".leaflet-interactive")

    take_screenshot

  end

end
