require 'test_helper'
require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class CommentTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  def setup
    visit '/'

    find(".nav-link.loginToggle").click()
    fill_in("username-login", with: "jeff")
    fill_in("password-signup", with: "secretive")

    find(".login-modal-form #login-button").click()
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

    # replying to the comment
    first("p", text: "Reply to this comment...").click()

    fill_in("body", with: "Awesome Reply")

    # preview reply
    first("#post_comment").click
    find("p", text: "Awesome Reply")
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

  test 'comment image upload' do
    Capybara.ignore_hidden_elements = false
    visit "/wiki/wiki-page-path/comments"

    find("p", text: "Reply to this comment...").click()

    reply_preview_button = page.all('#post_comment')[0]
    fileinput_element = page.all('#fileinput')[0]

    # Upload the image
    fileinput_element.set("#{Rails.root.to_s}/public/images/pl.png")

    # Wait for image upload to finish
    wait_for_ajax
    Capybara.ignore_hidden_elements = true

    # Toggle preview
    reply_preview_button.click()

    # Make sure that image has been uploaded
    page.assert_selector('#preview img', count: 1)
  end
  
  test 'comment image upload by choose one' do
    Capybara.ignore_hidden_elements = false
    visit "/wiki/wiki-page-path/comments"

    find("p", text: "Reply to this comment...").click()
    first("a", text: "choose one").click() 

    reply_preview_button = page.all('#post_comment')[0]
    fileinput_element = page.all('#fileinput')[0]

    # Upload the image
    fileinput_element.set("#{Rails.root.to_s}/public/images/pl.png")

    # Wait for image upload to finish
    wait_for_ajax
    Capybara.ignore_hidden_elements = true

    # Toggle preview
    reply_preview_button.click()

    # Make sure that image has been uploaded
    page.assert_selector('#preview img', count: 1)
  end
  test 'comment image drag and drop upload' do
    Capybara.ignore_hidden_elements = false
    visit "/wiki/wiki-page-path/comments"

    find("p", text: "Reply to this comment...").click()

    reply_preview_button = page.all('#post_comment')[0]

    # Upload the image
    drop_in_dropzone("#{Rails.root.to_s}/public/images/pl.png", ".dropzone")

    # Wait for image upload to finish
    wait_for_ajax
    Capybara.ignore_hidden_elements = true

    # Toggle preview
    reply_preview_button.click()

    # Make sure that image has been uploaded
    page.assert_selector('#preview img', count: 1)
  end

  test 'ctrl/cmd + enter comment publishing keyboard shortcut' do
    visit "/wiki/wiki-page-path/comments"

    find("p", text: "Reply to this comment...").click()

    # Write a comment
    page.all("#text-input")[1].set("Great post!")

    page.execute_script <<-JS
      // Remove first text-input field
      $("#text-input").remove()

      var $textBox = $("#text-input");

      // Generate fake CTRL + Enter event
      var press = jQuery.Event("keypress");
      press.altGraphKey = false;
      press.altKey = false;
      press.bubbles = true;
      press.cancelBubble = false;
      press.cancelable = true;
      press.charCode = 10;
      press.clipboardData = undefined;
      press.ctrlKey = true;
      press.currentTarget = $textBox[0];
      press.defaultPrevented = false;
      press.detail = 0;
      press.eventPhase = 2;
      press.keyCode = 10;
      press.keyIdentifier = "";
      press.keyLocation = 0;
      press.layerX = 0;
      press.layerY = 0;
      press.metaKey = false;
      press.pageX = 0;
      press.pageY = 0;
      press.returnValue = true;
      press.shiftKey = false;
      press.srcElement = $textBox[0];
      press.target = $textBox[0];
      press.type = "keypress";
      press.view = Window;
      press.which = 10;

      // Emit fake CTRL + Enter event
      $textBox.trigger(press);
    JS

    assert_selector('#comments-list .comment', count: 2)
    assert_selector('.noty_body', text: 'Comment Added!')
  end

  test 'comment deletion' do
    visit "/wiki/wiki-page-path/comments"

    # Create a comment
    page.execute_script <<-JS
      var commentForm = $('.comment-form-wrapper')[1];
      var submitCommentBtn = $(commentForm).find('.btn')[0];
      var commentTextarea = $(commentForm).find('#text-input')[0]

      $(commentTextarea).val('Great post Jeff!')
      $(submitCommentBtn).click()
    JS

    # Delete a comment
    find('.btn[data-original-title="Delete comment"]', match: :first).click()

    # Click "confirm" on modal
    page.evaluate_script('document.querySelector(".jconfirm-buttons .btn:first-of-type").click()')

    assert_selector('#comments-list .comment', count: 1)
    assert_selector('.noty_body', text: 'Comment deleted')
  end

  test 'comment editing' do
    visit "/wiki/wiki-page-path/comments"

    # Create a comment
    page.execute_script <<-JS
      var commentForm = $('.comment-form-wrapper')[1];
      var submitCommentBtn = $(commentForm).find('.btn')[0];
      var commentTextarea = $(commentForm).find('#text-input')[0]

      // Fill the form
      $(commentTextarea).val('Great post Jeff!')
      $(submitCommentBtn).click()
    JS

    # Wait for comment to upload
    wait_for_ajax

    # Edit the comment
    page.execute_script <<-JS
      var comment = $(".comment")[1];
      var commentID = comment.id;
      var editCommentBtn = $(comment).find('.navbar-text #edit-comment-btn')

      // Toggle edit mode
      $(editCommentBtn).click()

      var commentTextarea = $('#' + commentID + 'text');
      $(commentTextarea).val('Updated comment.')

      var submitCommentBtn = $('#' + commentID + ' .control-group .btn-primary')[1];
      $(submitCommentBtn).click()
    JS

    message = find('.alert-success', match: :first).text
    assert_equal( "×\nComment updated.", message)
  end

  test "reacting and unreacting to comment" do
    note = nodes(:one)
    visit note.path
    
    first(".comment #dropdownMenuButton").click()

    # click on thumbs up
    find("img[src='https://github.githubassets.com/images/icons/emoji/unicode/1f44d.png']").click()
    page.assert_selector("button[data-original-title='jeff reacted with thumbs up emoji']")

    first("img[src='https://github.githubassets.com/images/icons/emoji/unicode/1f44d.png']").click()
    page.assert_no_selector("button[data-original-title='jeff reacted with thumbs up emoji'")
  end

end
