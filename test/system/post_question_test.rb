require "application_system_test_case"

class QuestionTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'viewing question post' do
    visit '/'

    find(".nav-link.loginToggle").click()


    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    find(".login-modal-form #login-button").click()


    visit '/questions/new'

    take_screenshot

  end

end
