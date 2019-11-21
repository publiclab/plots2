require "application_system_test_case"

class SimplePostTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'viewing simple editor post' do
    visit '/'

    click_on 'Login'

    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"

    visit '/post/simple'

    take_screenshot

  end

  test 'posting a wiki from simple editor' do
    #fill in and psot
     # visit '/'

    # click_on 'Login'

    # fill_in("username-login", with: "Bob")
    # fill_in("password-signup", with: "secretive")
    # click_on "Log in"

    # visit '/post/simple'

  end
end
