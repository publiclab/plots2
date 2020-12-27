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

  # page_types are wiki, research note, question:
  page_types.each do |page_type, node_name|
    page_type_string = page_type.to_s
    comment_text = 'woot woot'
    comment_response_text = 'wooly woot'

    test "#{page_type_string}: addComment(comment_text)" do
      # wiki pages' comments, unlike questions' and notes', are viewable from /wiki/wiki-page-path/comments
      node_name == :wiki_page ? (visit nodes(node_name).path + '/comments') : (visit nodes(node_name).path)
      page.evaluate_script("addComment('#{comment_text}')")
      assert_selector('#comments-list .comment-body p', text: comment_text)
    end

    test "#{page_type_string}: addComment(comment_text, submit_url)" do
      node_name == :wiki_page ? (visit nodes(node_name).path + '/comments') : (visit nodes(node_name).path)
      page.evaluate_script("addComment('#{comment_text}', '/comment/create/#{nodes(node_name).nid.to_s}')")
      assert_selector('#comments-list .comment-body p', text: comment_text)
    end

    test "#{page_type_string}: reply to existing comment" do
      node_name == :wiki_page ? (visit nodes(node_name).path + '/comments') : (visit nodes(node_name).path)
      # find comment ID of the first comment on page
      parent_id = "#" + page.find('#comments-list').first('.comment')[:id]
      parent_id_num = /c(\d+)/.match(parent_id)[1] # eg. comment ID format is id="c9834"
      # addComment(comment text, submitURL, comment's parent ID)
      page.evaluate_script("addComment(\"no you can't\", '/comment/create/#{nodes(:comment_note).nid}', #{parent_id_num})")
      # check for comment text
      assert_selector("#{parent_id} .comment .comment-body p", text: 'no you can\'t')
    end

    test "#{page_type_string}: comment, then reply to FRESH comment" do
      visit nodes(:comment_question).path
      # post new comment
      comment_text = 'woot woot'
      page.evaluate_script("addComment('#{comment_text}', '/comment/create/#{nodes(:comment_question).nid}')")
      # we need the ID of parent div that contains <p>comment_text</p>:
      parent_id = page.find('p', text: comment_text).find(:xpath, '..')[:id]
      # regex to strip the ID number out of string. ID format is comment-body-4231
      parent_id_num = /comment-body-(\d+)/.match(parent_id)[1]
      # reply to comment
      comment_response_text = 'wooly woot!'
      # addComment(comment text, submitURL, comment's parent ID)
      page.evaluate_script("addComment('#{comment_response_text}', '/comment/create/#{nodes(:comment_question).nid}', #{parent_id_num})")
      # assert that <div id="c1show"> has child div[div[p[text="wooly woot!"]]]
      assert_selector("#{'#c' + parent_id_num + 'show'} div div div p", text: comment_response_text)
    end

    test "#{page_type_string}: manual comment and reply to comment" do
      node_name == :wiki_page ? (visit nodes(node_name).path + '/comments') : (visit nodes(node_name).path)
      fill_in("body", with: comment_text)
      # preview comment
      find("#post_comment").click
      find("p", text: comment_text)
      # publish comment
      click_on "Publish"
      find(".noty_body", text: "Comment Added!")
      find("p", text: comment_text)
      # replying to the comment
      first("p", text: "Reply to this comment...").click()
      fill_in("body", with: comment_response_text)
      # preview reply
      first("#post_comment").click
      find("p", text: comment_response_text)
    end

    test "#{page_type_string}: comment preview button works" do
      node_name == :wiki_page ? (visit nodes(node_name).path + '/comments') : (visit nodes(node_name).path)
      find("p", text: "Reply to this comment...").click()
      reply_preview_button = page.all('#post_comment')[0]
      comment_preview_button = page.all('#post_comment')[1]
      # Toggle preview
      reply_preview_button.click()
      # Make sure that buttons are not binded with each other
      assert_equal( reply_preview_button.text, "Hide Preview" )
      assert_equal( comment_preview_button.text, "Preview" )
    end

    test "#{page_type_string}: comment image upload" do
      Capybara.ignore_hidden_elements = false
      node_name == :wiki_page ? (visit nodes(node_name).path + '/comments') : (visit nodes(node_name).path)
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

    test "#{page_type_string}: comment image upload by choose one" do
      Capybara.ignore_hidden_elements = false
      node_name == :wiki_page ? (visit nodes(node_name).path + '/comments') : (visit nodes(node_name).path)
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

    test "#{page_type_string}: comment image drag and drop upload" do
      Capybara.ignore_hidden_elements = false
      node_name == :wiki_page ? (visit nodes(node_name).path + '/comments') : (visit nodes(node_name).path)
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

    # bugs can occur if we upload an image to the main comment form, and then try to upload an image into edit comment.
    # the second image ends up in the main comment form, when it should end up in edit comment.
    # so the two forms can get 'cross-wired.'
    test "#{page_type_string}: check that edit form's select image upload isn't cross-wired with post comment form" do
      node_name == :wiki_page ? (visit nodes(node_name).path + '/comments') : (visit nodes(node_name).path)

      # post a fresh comment
      # find the main comment form at the bottom of the page, and save for reuse
      main_comment_form =  page.find('h4', text: /Post comment|Post Comment/).find(:xpath, '..') # title text on wikis is 'Post comment'
      # fill out the comment form
      main_comment_form
        .find('textarea')
        .click
        .fill_in with: comment_text
      # publish
      main_comment_form
        .find('button', text: 'Publish')
        .click
      page.find(".noty_body", text: "Comment Added!")

      # now we upload the images.
      # the <inputs> that take image uploads are hidden, so reveal them for finder:
      Capybara.ignore_hidden_elements = false
      
      # we need to make the main comment form the focus by clicking on "Preview," then hiding preview.
      # otherwise, image upload to main comment form will fail.
      main_comment_form.find('a', text: 'Preview').click.click
      # upload an image in the main comment form
      main_comment_form.all('#fileinput')[1].set("#{Rails.root.to_s}/public/images/pl.png")
      wait_for_ajax

      # we need the selector of the EDIT comment's #fileinput
      # first find the parent comment ID:
      comment_id = page.find('p', text: comment_text).find(:xpath, '..')[:id]
      # regex to strip the ID number out of string. ID format is comment-body-4231
      comment_id_num = /comment-body-(\d+)/.match(comment_id)[1]
      # this is the ID of the edit form:
      edit_form_id = '#c' + comment_id_num + 'edit' 
      edit_image_selector = edit_form_id + ' #fileinput'

      # open the edit comment form:
      find("#edit-comment-btn").click
      # upload an image in the edit comment form:
      file_input_element = page.find(edit_image_selector)
      file_input_element.set("#{Rails.root.to_s}/public/images/pl.png")
      wait_for_ajax
      Capybara.ignore_hidden_elements = true

      # open the preview for the main comment form
      main_comment_form.find('a', text: 'Preview').click
      # once preview is open, the images are embedded in the page.
      # there should only be 1 image in the main comment form!
      preview_imgs = page.all('#preview img').size
      assert_equal(1, preview_imgs)
    end

    test "#{page_type_string}: ctrl/cmd + enter comment publishing keyboard shortcut" do
      node_name == :wiki_page ? (visit nodes(node_name).path + '/comments') : (visit nodes(node_name).path)
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

    test "#{page_type_string}: comment deletion" do
      node_name == :wiki_page ? (visit nodes(node_name).path + '/comments') : (visit nodes(node_name).path)
      # Create a comment
      page.execute_script <<-JS
        var commentForm = $('.comment-form-wrapper')[1];
        var submitCommentBtn = $(commentForm).find('.btn-primary')[0];
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

    test "#{page_type_string}: formatting toolbar is rendered" do
      node_name == :wiki_page ? (visit nodes(node_name).path + '/comments') : (visit nodes(node_name).path)
      assert_selector('.btn[data-original-title="Bold"]', count: 1)
      assert_selector('.btn[data-original-title="Italic"]', count: 1)
      assert_selector('.btn[data-original-title="Header"]', count: 1)
      assert_selector('.btn[data-original-title="Make a link"]', count: 1)
      assert_selector('.btn[data-original-title="Upload an image"]', count: 1)
      assert_selector('.btn[data-original-title="Save"]', count: 1)
      assert_selector('.btn[data-original-title="Recover"]', count: 1)
      assert_selector('.btn[data-original-title="Help"]', count: 1)
    end

    test "#{page_type_string}: edit comment" do
      node_name == :wiki_page ? (visit nodes(node_name).path + '/comments') : (visit nodes(node_name).path)
      # Create a comment
      page.execute_script <<-JS
        var commentForm = $('.comment-form-wrapper')[1];
        var submitCommentBtn = $(commentForm).find('.btn-primary')[0];
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

    test "#{page_type_string}: react and unreact to comment" do
      node_name == :wiki_page ? (visit nodes(node_name).path + '/comments') : (visit nodes(node_name).path)
      first(".comment #dropdownMenuButton").click()
      # click on thumbs up
      find("img[src='https://github.githubassets.com/images/icons/emoji/unicode/1f44d.png']").click()
      page.assert_selector("button[data-original-title='jeff reacted with thumbs up emoji']")
      first("img[src='https://github.githubassets.com/images/icons/emoji/unicode/1f44d.png']").click()
      page.assert_no_selector("button[data-original-title='jeff reacted with thumbs up emoji'")
    end
  end
end
