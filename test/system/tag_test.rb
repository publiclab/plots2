require 'test_helper'
require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class TagTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'adding a tag via javascript' do
    visit '/'

    click_on 'Login'

    fill_in("username-login", with: "jeff")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"

    visit "/wiki/wiki-page-path"

    # run the javascript function
    page.evaluate_script("addTag('bluebell')")

    # check that the tag showed up on the page
    assert_selector('.tags-list .tag-name', text: 'bluebell')

  end

  test 'adding a tag via javascript with url only' do
    visit '/'

    click_on 'Login'

    fill_in("username-login", with: "jeff")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"

    visit "/wiki/wiki-page-path"

    # run the javascript function
    page.evaluate_script("addTag('roses', '/tag/create/11')")

    # check that the tag showed up on the page
    assert_selector('.tags-list .tag-name', text: 'roses')

  end

  test 'adding a tag to a user profile' do
    visit '/'

    click_on 'Login'

    fill_in("username-login", with: "jeff")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"

    visit "/profile/jeff"

    # run the javascript function
    page.evaluate_script("addTag('specialgroup', '/profile/tags/create/2')")

    find('#tags-section').click

    # check that the tag showed up on the page - check last tag in list
    within('.tags-list') do
      assert_equal('specialgroup', all('.tag-name').last.text.rstrip.lstrip)
    end

  end

end
