require 'test_helper'
require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class TagTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  def setup
    visit '/'

    find(".nav-link.loginToggle").click()
    fill_in("username-login", with: "jeff")
    fill_in("password-signup", with: "secretive")

    find(".login-modal-form #login-button").click()
  end

  test 'adding a tag via javascript' do
    visit "/wiki/wiki-page-path"

    # run the javascript function
    page.evaluate_script("addTag('bluebell')")

    # check that the tag showed up on the page
    assert_selector('.tags-list .tag-name', text: 'bluebell')

  end

  test 'adding a tag via javascript with url only' do
    visit "/wiki/wiki-page-path"

    # run the javascript function
    page.evaluate_script("addTag('roses', '/tag/create/11')")

    # check that the tag showed up on the page
    assert_selector('.tags-list .tag-name', text: 'roses')

  end

  test 'adding a tag to a user profile' do
    visit "/profile/jeff"

    # run the javascript function
    page.evaluate_script("addTag('specialgroup', '/profile/tags/create/2')")

    find('#tags-section').click

    # check that the tag showed up on the page - check last tag in list
    within('.tags-list') do
      assert_equal('specialgroup', all('.tag-name').last.text.rstrip.lstrip)
    end

  end

  test 'hide add tag form from first time posters' do
    visit "/wiki/wiki-page-path"

    # check whether element with id `tags-open` present or not for normal user
    assert_selector("#tags-open")
    
    find("#sidebar-tags a").click()
    # check whether element with id `tagform` present or not for normal user
    assert_selector("#tagform")

    # logout
    visit '/logout'
    visit '/'

    # login to first time user
    find(".nav-link.loginToggle").click()
    fill_in("username-login", with: "sushmita")
    fill_in("password-signup", with: "secretive")

    find(".login-modal-form #login-button").click()

    visit "/wiki/wiki-page-path"

    # check whether element with id `tags-open` present or not
    assert_selector("#tags-open", count: 0)
    
    find("#sidebar-tags a").click()

    # check whether element with id `tagform` present or not
    assert_selector("#tagform", count: 0)
    # check that the error message showed up on the page
    assert_selector(".popover-body", text: 'Adding tags to other people’s posts is not available to you until your own first post has been approved by site moderators')

  end

  test 'block adding tag using javascript by first time posters' do
    # logout
    visit '/logout'
    visit '/'

    # login to first time poster
    find(".nav-link.loginToggle").click()
    fill_in("username-login", with: "sushmita")
    fill_in("password-signup", with: "secretive")

    find(".login-modal-form #login-button").click()

    visit "/wiki/wiki-page-path"

    # run the javascript function
    page.evaluate_script("addTag('bluebell')")

    # check if tag showed up on the page
    assert_selector('.tags-list a', {count: 0, text: 'bluebell'})
  end

  test 'block adding tag using javascript with only url by first time posters' do
    # logout
    visit '/logout'
    visit '/'

    # login to first time poster
    find(".nav-link.loginToggle").click()
    fill_in("username-login", with: "sushmita")
    fill_in("password-signup", with: "secretive")

    find(".login-modal-form #login-button").click()

    visit "/wiki/wiki-page-path"

    # run the javascript function
    page.evaluate_script("addTag('mytag', '/tag/create/11')")

    # check if tag showed up on the page
    assert_selector('.tags-list a', {count: 0, text: 'mytag'})
  end
end
