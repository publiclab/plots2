require "application_system_test_case"

class ProfileTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'create and delete user tag using AJAX' do
    visit '/'
    click_on 'Login'
    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"

    visit '/profile/bob'

    find_link('tags-section', href: nil).click
    find_link('tags-open', href: nil).click
    find('.tag-input').set("test_user_tag\n")

    within('div#tags.profile-tags') do
      assert_selector('a', text: 'test_user_tag')
      find('p:last-of-type a', text: 'x').click
      assert_no_selector('a', text: 'test_user_tag')
    end
  end
end
