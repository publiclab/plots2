require 'test_helper'
require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class CommentTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60
  def setup
    visit '/'
    click_on 'Login'
    fill_in("username-login", with: "jeff")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"
  end
  test 'adding a comment via javascript' do
    visit "/wiki/wiki-page-path/comments"

    # run the javascript function
    page.evaluate_script("addComment('fantastic four')")

    # check that the tag showed up on the page
    assert_selector('#comments-list .comment-body p', text: 'fantastic four')
  end

  test 'adding a comment via javascript with url only' do
    visit "/wiki/wiki-page-path/comments"

    # run the javascript function
    page.evaluate_script("addComment('superhero', '/comment/create/11')")

    # check that the tag showed up on the page
    assert_selector('#comments-list .comment-body p', text: 'superhero')
  end
 
  test 'adding a reply comment via javascript with url only' do
    visit "/wiki/wiki-page-path/comments"

    # run the javascript function
    parentid = "#" + page.find('#comments-list').first('.comment')[:id]
    parentid_num = parentid.slice(2..-1)
    page.evaluate_script("addComment('batman', '/comment/create/11', #{parentid_num})")

    # check that the tag showed up on the page
    assert_selector("#{parentid} .comment .comment-body p", text: 'batman')
  end
  
  test "add a comment manually" do
    visit nodes(:one).path

    fill_in("body", with: "Awesome comment! :)")

    # preview comment
    find("#post_comment").click
    find("p", text: "Awesome comment! :)")

    # publish comment
    click_on "Publish"
    find(".noty_body", text: "Comment Added!")
    find("p", text: "Awesome comment! :)")
  end

  test 'comment preview button' do
    visit "/wiki/wiki-page-path/comments"

    find("p", text: "Reply to this comment...").click()

    reply_preview_button = page.all('#post_comment')[0]
    comment_preview_button = page.all('#post_comment')[1]

    # Toggle preview
    reply_preview_button.click()

    # Make sure that buttons are not binded with each other
    assert_equal( reply_preview_button.text, "Hide Preview" )
    assert_equal( comment_preview_button.text, "Preview" )
  end

end
