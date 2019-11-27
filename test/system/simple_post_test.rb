require "application_system_test_case"

class SimplePostTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'viewing simple editor post' do
    skip
    visit '/'

    click_on 'Login'

    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"

    visit '/post/simple'

    take_screenshot
  end
end
