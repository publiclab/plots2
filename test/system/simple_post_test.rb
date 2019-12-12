require "application_system_test_case"

class SimplePostTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'simple editor post' do
    visit '/'
    click_on 'Login'
    fill_in('username-login', with: 'steff1')
    fill_in('password-signup', with: 'secretive')
    click_on 'Log in'
    visit(simple_editor_path)

    take_screenshot

    fill_in('title-input', with: 'My story')
    fill_in('textarea', with: 'This is my story')
    find('button.ple-publish').click

    assert_selector('h1', text: "My story")
  end
end
