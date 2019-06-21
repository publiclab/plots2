require "application_system_test_case"

class QuestionTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'viewing question post' do
    visit '/'

    click_on 'Login'

    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"

    visit '/questions/new'

    take_screenshot

  end

end
