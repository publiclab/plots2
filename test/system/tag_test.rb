require 'test_helper'
require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class TagTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'adding a tag with javascript' do
    visit '/'

    click_on 'Login'

    fill_in("username-login", with: "jeff")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"

    visit "/wiki/wiki-page-path"

    find('#tags-open').click
    
    #fill_in("searchform_input", with: "test")
    #find('button.btn-light').click

    assert page.evaluate_script("addTag('bluebell')")

    # check that the tag showed up on the page
    #assert_selector('#sidebar-tags.badge', text: 'bluebell')

  end

end
