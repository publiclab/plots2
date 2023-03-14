require 'test_helper'
require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class CommentSystemTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  def setup
    visit '/'

    find(".nav-link.loginToggle").click()
    fill_in("username-login", with: "jeff")
    fill_in("password-signup", with: "secretive")

    find(".login-modal-form #login-button").click()
  end

  def get_path(page_type, path)
    # wiki pages' comments, unlike questions' and notes', are viewable from /wiki/wiki-page-path/comments
    page_type == :wiki ? path + '/comments' : path
  end

  comment_text = 'woot woot'
  comment_response_text = 'wooly woot'

  # comment system tests are divided into 3 parts:
  #   1. basic CRUD in both React and Rails research notes
  #   2. tests for research notes
  #   3. tests for research notes, wikis, and questions

  # PART 1: TESTS FOR BASIC CRUD (REACT & RAILS NOTES)
  # system tests for BASIC commenting CRUD functionality:
  #   create (posting comments & replies)
  #   update (editing comments)
  #   delete
  [true, false].each do |is_testing_react|
    page_type_string = is_testing_react ? 'react note' : 'rails note'
    test_path = is_testing_react ? '?react=true' : ''

    test "#{page_type_string}: post comment" do
      visit nodes(:comment_note).path + test_path
      main_comment_form = page.find('#comment-form-main')
      # fill in comment text
      main_comment_form
        .find('#text-input-main')
        .click
        .fill_in with: comment_text
      # click publish button
      main_comment_form
        .find('button', text: 'Publish')
        .click
      # wait for notyNotification to appear
      find(".noty_body", text: "Comment Added!")
      # assert that comment has appeared
      assert_selector('#comments-list .comment-body p', text: comment_text)
    end

    test "#{page_type_string}: post REPLY to comment" do
      visit nodes(:comment_note).path + test_path
      # find the first comment
      first_comment = page.first('.comment')
      # click on the reply form toggle
      first_comment
        .find('p', text: 'Reply to this comment...')
        .click
      # enter text in reply form
      first_comment.find('[id^=text-input-reply-]')
        .click
        .fill_in with: comment_response_text
      # click publish button
      first_comment
        .find('button', text: 'Publish')
        .click
      # wait for notyNotification to appear
      page.find(".noty_body", text: "Comment Added!")
      assert_selector('.comment .comment .comment-body p', text: comment_response_text)
    end

    test "#{page_type_string}: edit comment" do
      nodes(:comment_note).add_comment({
        uid: 2,
        body: comment_text
      })
      visit nodes(:comment_note).path + test_path
      # open up the edit comment form
      page
        .find('.edit-comment-btn')
        .click
      # find the edit form's textarea
      textarea = page.find('[id^=text-input-edit-]', text: comment_text)
      # extract the comment's ID from the textarea
      textarea_id = textarea[:id]
      comment_id_num = /text-input-edit-(\d+)/.match(textarea_id)[1]
      # click on the textarea, and enter updated comment text
      textarea
        .click
        .fill_in with: 'new comment text!'
      # click the publish button
      page
        .find('#comment-form-edit-' + comment_id_num)
        .find('button', text: 'Publish')
        .click
      # revisit the page. why? currently rails comments reload the page, react comments don't reload, but update the DOM.
      visit nodes(:comment_note).path + test_path
      assert_selector('#comments-list .comment-body p', text: 'new comment text!')
    end

    test "#{page_type_string}: delete comment" do
      # add comment by test user before page loads
      # after this, there should be 2 comments total
      nodes(:comment_note).add_comment({
        uid: 2,
        body: comment_text
      })
      visit nodes(:comment_note).path + test_path
      # click the delete button
      comment = page.all('.delete-comment-btn')[1].click
      if !is_testing_react
      # there's an extra step to confirm deletion in rails commenting system
        page
          .find('button', text: 'confirm')
          .click
      end
      wait_for_ajax
      number_of_comments = page.all('.comment').length
      # after deleting 1 comment, there should be 1 left.
      assert_equal(number_of_comments, 1)
    end
  end

  # PART 2: TESTS FOR RESEARCH NOTES ONLY
  #    public lab has 3 different page types: research notes, wikis, and questions
  #    to save testing resources, we can run most tests on just research notes
  { :note => :comment_note }.each do |page_type, node_name|
    page_type_string = 'note'

    test "#{page_type_string}: addComment(comment_text)" do
      visit get_path(page_type, nodes(node_name).path)
      page.evaluate_script("addComment('#{comment_text}')")
      assert_selector('#comments-list .comment-body p', text: comment_text)
    end

    test "#{page_type_string}: addComment(comment_text, submit_url)" do
      visit get_path(page_type, nodes(node_name).path)
      page.evaluate_script("addComment('#{comment_text}', '/comment/create/#{nodes(node_name).nid.to_s}')")
      assert_selector('#comments-list .comment-body p', text: comment_text)
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

    test "#{page_type_string}: toggle preview buttons work" do
      nodes(node_name).add_comment({
        uid: 2,
        # **bold**
        body: "**" + comment_text + "**"
      })
      visit get_path(page_type, nodes(node_name).path)

      # open up reply comment form
      page.all('p', text: 'Reply to this comment...')[0].click
      # get the ID of reply form
      reply_form = page.find('[id^=comment-form-reply-]')
      reply_form_id = reply_form[:id]
      reply_id_num = /comment-form-reply-(\d+)/.match(reply_form_id)[1]
      page.find('#text-input-reply-' + reply_id_num)
        .click
        .fill_in with: "**" + comment_text + "**"

      # open up edit comment form
      page.find(".edit-comment-btn").click
      # get the ID of edit form
      edit_form = page.find('[id^=comment-form-edit-]')
      edit_form_id = edit_form[:id]
      edit_id_num = /comment-form-edit-(\d+)/.match(edit_form_id)[1]
      page.find('#text-input-edit-' + edit_id_num)
        .click
        .fill_in with: "**" + comment_text + "**"

      # fill out main comment form
      main_form = page.find('#text-input-main')
      main_form
        .click
        .fill_in with: "**" + comment_text + "**"

      # click on toggle preview buttons for main, edit, and reply
      replyPreviewButton = page.find('#toggle-preview-button-reply-' + reply_id_num)
      editPreviewButton = page.find('#toggle-preview-button-edit-' + edit_id_num)
      mainPreviewButton = page.find('#toggle-preview-button-main')
      replyPreviewButton.click
      editPreviewButton.click
      mainPreviewButton.click

      # assert preview element appears
      assert_selector('#comment-preview-edit-' + edit_id_num)
      assert_selector('#comment-preview-reply-' + reply_id_num)
      assert_selector('#comment-preview-main')
      # assert that button text says Hide Preview
      assert_equal(replyPreviewButton.text, 'Hide Preview')
      assert_equal(editPreviewButton.text, 'Hide Preview')
      assert_equal(mainPreviewButton.text, 'Hide Preview')
      # assert text is woot woot, not **woot woot**
      reply_form.has_no_text? '**' + comment_text + '**'
      edit_form.has_no_text? '**' + comment_text + '**'
      main_form.has_no_text? '**' + comment_text + '**'
    end

    test "#{page_type_string}: ctrl/cmd + enter comment publishing keyboard shortcut" do
      visit get_path(page_type, nodes(node_name).path)
      find("p", text: "Reply to this comment...").click()
      # Write a comment
      page.all(".text-input")[1].set("Great post!")
      page.execute_script <<-JS
        // Remove first text-input field
        $(".text-input").first().remove()
        var $textBox = $(".text-input");
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

    test "#{page_type_string}: formatting toolbar is rendered" do
      visit get_path(page_type, nodes(node_name).path)
      assert_selector('.btn[data-original-title="Bold"]', count: 1)
      assert_selector('.btn[data-original-title="Italic"]', count: 1)
      assert_selector('.btn[data-original-title="Header"]', count: 1)
      assert_selector('.btn[data-original-title="Link"]', count: 1)
      assert_selector('.btn[data-original-title="Upload Image"]', count: 1)
      assert_selector('.btn[data-original-title="Save"]', count: 1)
      assert_selector('.btn[data-original-title="Recover"]', count: 1)
      assert_selector('.btn[data-original-title="Help"]', count: 1)
    end

    test "#{page_type_string}: react and unreact to comment" do
      visit get_path(page_type, nodes(node_name).path)
      first(".comment #dropdownMenuButton").click()
      # click on thumbs up
      find("img[src='https://github.githubassets.com/images/icons/emoji/unicode/1f44d.png']").click()
      page.assert_selector("button[data-original-title='jeff reacted with thumbs up emoji']")
      first("img[src='https://github.githubassets.com/images/icons/emoji/unicode/1f44d.png']").click()
      page.assert_no_selector("button[data-original-title='jeff reacted with thumbs up emoji'")
    end

    test "#{page_type}: multiple comment boxes, post comments" do
      if page_type == :note
        visit nodes(:note_with_multiple_comments).path
      elsif page_type == :question
        visit nodes(:question_with_multiple_comments).path
      elsif page_type == :wiki
        visit nodes(:wiki_with_multiple_comments).path + '/comments'
      end
      # there should be multiple "Reply to comment..."s on this fixture
      reply_toggles = page.all('p', text: 'Reply to this comment...')
      # extract the comment IDs from each
      comment_ids = []
      reply_toggles.each do |reply_toggle|
        id_string = reply_toggle[:id]
        comment_id = /comment-(\d+)-reply-toggle/.match(id_string)[1]
        comment_ids << comment_id
      end
      # work with just the 2nd comment
      reply_toggles[1].click 

      # check if the comment form reply textarea has no content on input field
      assert_selector("#comment-form-reply-#{comment_ids[1]} textarea.text-input", text: "")

      # open the comment form by toggling, and fill in some text
      find("div#comment-#{comment_ids[1]}-reply-section textarea.text-input").click.fill_in with: 'H'
      
      # open the other two comment forms
      reply_toggles[0].click
      # check if the comment form reply textarea has no content on input field
      assert_selector("#comment-form-reply-#{comment_ids[0]} textarea.text-input", text: "")

      reply_toggles[2].click
      # check if the comment form reply textarea has no content on input field
      assert_selector("#comment-form-reply-#{comment_ids[2]} textarea.text-input", text: "")
      
      # fill them in with text
      find("div#comment-#{comment_ids[0]}-reply-section textarea.text-input").click.fill_in with: 'A'
      find("div#comment-#{comment_ids[2]}-reply-section textarea.text-input").click.fill_in with: 'Y'
      # click the publish buttons for each in a random sequence
      [1, 2, 0].each do |number|
        find("div#comment-#{comment_ids[number]}-reply-section button", text: 'Publish').click
        wait_for_ajax
      end
      # assert that the replies went to the right comments
      assert_selector("#c" + comment_ids[0] + "show div div div p", text: 'A')
      assert_selector("#c" + comment_ids[1] + "show div div div p", text: 'H')
      assert_selector("#c" + comment_ids[2] + "show div div div p", text: 'Y')
    end

    test "#{page_type_string}: progress bars display for image DRAG & DROP in MAIN comment form" do
      node_name == :wiki_page ? (visit nodes(node_name).path + '/comments') : (visit nodes(node_name).path)
      # make a fresh comment in the main comment form
      main_comment_form =  page.find('h4', text: /Post comment|Post Comment/).find(:xpath, '..') # title text on wikis is 'Post comment'
      # before we drop an image, we need to make the main comment form the focus by clicking on "Preview," then hiding preview.
      # otherwise, image upload in the next step won't be 'wired' to the "Post Comment" form.
      main_comment_form.find('a', text: 'Preview').click.click
      # .dropzone is hidden, so reveal it:
      Capybara.ignore_hidden_elements = false
      # drag & drop the image. drop_in_dropzone simulates 'drop' event,  see application_system_test_case.rb
      drop_in_dropzone("#{Rails.root.to_s}/public/images/pl.png", '#comments-list + div .dropzone-large') # this CSS selects .dropzones that belong to sibling element immediately following #comments-list. technically, there are two .dropzones in the main comment form.
      Capybara.ignore_hidden_elements = true
      assert_selector('.progress')
      assert_selector('.uploading-text')
    end

    test "#{page_type_string}: progress bars display for EDIT comment form's image SELECT upload" do
      # before we visit the page, add a jeff comment so that we can edit it.
      nodes(node_name).add_comment({
        uid: 2,
        body: comment_text
      })
      visit get_path(page_type, nodes(node_name).path)
      # open the edit comment form:
      page.find(".edit-comment-btn").click
      # find the parent of edit comment's fileinput:
      comment_fileinput_parent_id = page.find('[id^=dropzone-small-edit-]')[:id] # 'begins with' CSS selector
      comment_id_num = /dropzone-small-edit-(\d+)/.match(comment_fileinput_parent_id)[1]
      # upload images
      # the <inputs> that take image uploads are hidden, so reveal them:
      Capybara.ignore_hidden_elements = false
      # find edit comment's fileinput:
      page.find('#fileinput-button-edit-' + comment_id_num).set("#{Rails.root.to_s}/public/images/pl.png")
      Capybara.ignore_hidden_elements = true
      assert_selector('#image-upload-progress-container-edit-' + comment_id_num)
      assert_selector('#image-upload-text-edit-' + comment_id_num)
    end

    test "#{page_type_string}: save & recover buttons work" do
      # quick-add an editable comment before visiting page
      nodes(node_name).add_comment({
        uid: 2,
        body: comment_text
      })
      visit get_path(page_type, nodes(node_name).path)

      comment_text_main = 'Waffles'
      comment_text_reply = 'Eggs and Bacon'
      comment_text_edit = 'Fruit & Yogurt'

      # type some text into main comment form
      page.find('#text-input-main')
        .click
        .fill_in with: comment_text_main
        # taking into account the time for debounce function
        sleep(0.7)

      # open up reply comment form
      page.all('p', text: 'Reply to this comment...')[0].click
      # get the ID of reply form
      reply_form = page.find('[id^=comment-form-reply-]')
      reply_form_id = reply_form[:id]
      reply_id_num = /comment-form-reply-(\d+)/.match(reply_form_id)[1]
      page.find('#text-input-reply-' + reply_id_num)
        .click
        .fill_in with: comment_text_reply
        # taking into account the time for debounce function
        sleep(0.7)

      # open up edit comment form
      page.find(".edit-comment-btn").click
      # get the ID of edit form
      edit_form = page.find('[id^=comment-form-edit-]')
      edit_form_id = edit_form[:id]
      edit_id_num = /comment-form-edit-(\d+)/.match(edit_form_id)[1]
      page.find('#text-input-edit-' + edit_id_num)
        .click
        .fill_in with: comment_text_edit
        # taking into account the time for debounce function
        sleep(0.7)
      
      # visit the page again (ie. refresh it)
      visit get_path(page_type, nodes(node_name).path)
      page.find('#recover-button-main').click
      # click on reply recover button
      page.all('p', text: 'Reply to this comment...')[0].click
      page.find('#recover-button-reply-' + reply_id_num).click
      # click on edit recover button
      page.find('.edit-comment-btn').click
      page.find('#recover-button-edit-' + edit_id_num).click
      main_text = page.find('#text-input-main').value
      reply_text = page.find('#text-input-reply-' + reply_id_num).value
      edit_text = page.find('#text-input-edit-' + edit_id_num).value
      assert_equal(main_text, comment_text_main)
      assert_equal(reply_text, comment_text_reply)
      assert_equal(edit_text, comment_text_edit)
    end

    test "#{page_type_string}: rich-text change and image upload work on editing FRESH comment" do
      visit get_path(page_type, nodes(node_name).path)
      # make a fresh comment in the main comment form
      main_comment_form =  page.find('#comment-form-main')
      # fill out the comment form
      main_comment_form.find('#text-input-main')
        .click
        .fill_in with: comment_text
      # publish
      main_comment_form
        .find('button', text: 'Publish')
        .click
      page.find(".noty_body", text: "Comment Added!")
      # we need the ID of parent div that contains <p>comment_text</p>:
      fresh_comment_id = page.find('p', text: comment_text).find(:xpath, '..')[:id]
      # regex to strip the ID number out of string. ID format is comment-body-4231
      fresh_comment_id_num = /comment-body-(\d+)/.match(fresh_comment_id)[1]
      # open up the edit comment form
      page.find(".edit-comment-btn").click
      # click on the Bold rich-text button
      page.find("#bold-button-edit-" + fresh_comment_id_num).click
      # find what's in the textarea
      edit_input_value = page.find('#text-input-edit-' + fresh_comment_id_num).value
      # 1st assertion: check if bold (****) text is in the textarea!
      assert_equal('****' + comment_text, edit_input_value)
      # upload image by select
      Capybara.ignore_hidden_elements = false
      page.find('#fileinput-button-edit-' + fresh_comment_id_num).set("#{Rails.root.to_s}/public/images/pl.png")
      Capybara.ignore_hidden_elements = true
      wait_for_ajax
      # click on comment preview button
      page.find('#comment-form-edit-' + fresh_comment_id_num + ' a', text: 'Preview').click
      # 2nd assertion: check if image uploaded
      assert_selector('#comment-preview-edit-' + fresh_comment_id_num + ' img', count: 1)
    end

    test "#{page_type_string}: prefetch recently active users" do
      visit get_path(page_type, nodes(node_name).path) 
      page.find('#text-input-main').click.fill_in with: '@'
      # checks for the list of recently active users
      assert_selector('#atwho-ground-text-input-main .atwho-view .atwho-view-ul li')
    end

    test "#{page_type_string}: IMMEDIATE image SELECT upload into REPLY comment form" do
      nodes(node_name).add_comment({
        uid: 5,
        body: comment_text
      })
      nodes(node_name).add_comment({
        uid: 2,
        body: comment_text
      })
      visit get_path(page_type, nodes(node_name).path)
      reply_toggles = page.all('p', text: 'Reply to this comment...')
      reply_toggles[2].click
      reply_dropzone_id = page.find('[id^=dropzone-small-reply-]')[:id] # ID begins with...
      comment_id_num = /dropzone-small-reply-(\d+)/.match(reply_dropzone_id)[1]
      # upload images
      # the <inputs> that take image uploads are hidden, so reveal them:
      Capybara.ignore_hidden_elements = false
      # upload an image in the reply comment form
      page.find('#fileinput-button-reply-' + comment_id_num).set("#{Rails.root.to_s}/public/images/pl.png")
      wait_for_ajax
      Capybara.ignore_hidden_elements = true
      page.all('a', text: 'Preview')[0].click
      assert_selector('#comment-' + comment_id_num + '-reply-section img', count: 1)
    end

    test "#{page_type_string}: IMMEDIATE image DRAG & DROP into REPLY comment form" do
      Capybara.ignore_hidden_elements = false
      visit get_path(page_type, nodes(node_name).path)
      find("p", text: "Reply to this comment...").click()
      # Upload the image
      drop_in_dropzone("#{Rails.root.to_s}/public/images/pl.png", ".dropzone-large")
      # Wait for image upload to finish
      wait_for_ajax
      Capybara.ignore_hidden_elements = true
      # Toggle preview
      reply_preview_button = page.all('.preview-btn')[0]
      reply_preview_button.click()
      # Make sure that image has been uploaded
      page.assert_selector('.comment-preview img', count: 1)
    end

    test "#{page_type_string}: IMMEDIATE image CHOOSE ONE upload into REPLY comment form" do
      Capybara.ignore_hidden_elements = false
      visit get_path(page_type, nodes(node_name).path)
      # Open reply comment form
      find("p", text: "Reply to this comment...").click()
      first("a", text: "choose one").click() 
      reply_preview_button = page.first('a', text: 'Preview')
      Capybara.ignore_hidden_elements = false
      # Upload the image
      fileinput_element = page.first("[id^=fileinput-button-reply]")
      fileinput_element.set("#{Rails.root.to_s}/public/images/pl.png")
      Capybara.ignore_hidden_elements = true
      wait_for_ajax
      # Toggle preview
      reply_preview_button.click()
      # Make sure that image has been uploaded
      page.assert_selector('.comment-preview img', count: 1)
    end

    test "#{page_type_string}: IMMEDIATE rich-text input works in MAIN form" do
      visit get_path(page_type, nodes(node_name).path)
      main_comment_form =  page.find('h4', text: /Post comment|Post Comment/).find(:xpath, '..') # title text on wikis is 'Post comment'
      main_comment_form.find("[data-original-title='Bold']").click
      text_input_value = main_comment_form.find('#text-input-main').value
      assert_equal(text_input_value, '****')
    end

    # navigate to page, immediately upload into EDIT form by SELECTing image
    test "#{page_type_string}: IMMEDIATE image SELECT upload into EDIT comment form" do
      nodes(node_name).add_comment({
        uid: 2,
        body: comment_text
      })
      visit get_path(page_type, nodes(node_name).path)
      # open up the edit comment form
      page.find(".edit-comment-btn").click
      edit_comment_form = page.find('h4', text: 'Edit comment').find(:xpath, '..')
      # we need the comment ID:
      edit_comment_form_id = edit_comment_form[:id]
      # regex to strip the ID number out of string. ID format is #c1234edit
      comment_id_num = /comment-form-edit-(\d+)/.match(edit_comment_form_id)[1]
      edit_preview_id = '#comment-preview-edit-' + comment_id_num
      # the <inputs> that take image uploads are hidden, so reveal them:
      Capybara.ignore_hidden_elements = false
      file_input_element = edit_comment_form.all('input')[1]
      file_input_element.set("#{Rails.root.to_s}/public/images/pl.png")
      wait_for_ajax
      Capybara.ignore_hidden_elements = true
      # open edit comment preview
      edit_comment_form.find('a', text: 'Preview').click
      # there should be 1 preview image in the edit comment
      assert_selector("#{edit_preview_id} img", count: 1)
    end

    test "#{page_type_string}: should list first time replied comment to moderator" do
      comment = nodes(node_name).add_comment({
        uid: 19,
        body: "This is a first time reply",
        status: 4,
        reply_to: 1,
      })
      visit get_path(page_type, nodes(node_name).path)
      page.find("#c#{comment.id}")
      assert_equal comment.status, 4
      assert_selector("#c#{comment.id} div p", text: "Moderate first-time comment:")
    end

    test "#{page_type_string}: should not list first time replied comment to non-registered user" do
      comment = nodes(node_name).add_comment({
        uid: 19,
        body: "This is a first time reply",
        status: 4,
        reply_to: 1,
      })
      visit '/logout'
      visit get_path(page_type, nodes(node_name).path)
      assert_selector("#c#{comment.id}", count: 0)
    end

    test "#{page_type_string}: should not list first time replied comment to other user" do
      comment = nodes(node_name).add_comment({
        uid: 19,
        body: "This is a first time reply",
        status: 4,
        reply_to: 1,
      })
      visit '/logout'
      visit '/'

      find(".nav-link.loginToggle").click()
      fill_in("username-login", with: "sushmita")
      fill_in("password-signup", with: "secretive")

      find(".login-modal-form #login-button").click()
      visit get_path(page_type, nodes(node_name).path)
      assert_selector("#c#{comment.id}", count: 0)
    end

    test "#{page_type_string}: should not list spam replied comment to moderator" do
      comment = nodes(node_name).add_comment({
        uid: 5,
        body: "This is a spam reply",
        reply_to: 1,
      })
      visit "/admin/mark_comment_spam/#{comment.id}"
      visit get_path(page_type, nodes(node_name).path)
      assert_selector("#c#{comment.id}", count: 0)
    end

    test "#{page_type_string}: should not list spam replied comment to non-registered user" do
      comment = nodes(node_name).add_comment({
        uid: 5,
        body: "This is a spam reply",
        reply_to: 1,
      })
      visit "/admin/mark_comment_spam/#{comment.id}"
      visit '/logout'
      visit get_path(page_type, nodes(node_name).path)
      assert_selector("#c#{comment.id}", count: 0)
    end

    test "#{page_type_string}: should not list spam replied comment to registered user" do
      comment = nodes(node_name).add_comment({
        uid: 5,
        body: "This is a spam reply",
        reply_to: 1,
      })
      visit "/admin/mark_comment_spam/#{comment.id}"
      visit '/logout'
      visit '/'

      find(".nav-link.loginToggle").click()
      fill_in("username-login", with: "sushmita")
      fill_in("password-signup", with: "secretive")

      find(".login-modal-form #login-button").click()
      visit get_path(page_type, nodes(node_name).path)
      assert_selector("#c#{comment.id}", count: 0)
    end
  end

  # PART 3: TESTS for ALL PAGE TYPES!
  #
  # the page_types are: Wikis, Research Notes, and Questions
  # defined in test/test_helper.rb
  page_types.each do |page_type, node_name|
    page_type_string = page_type.to_s

    test "post #{page_type_string}, then comment on FRESH #{page_type_string}" do
      title_text, body_text = String.new, String.new
      case page_type_string
        when 'note'
          visit '/post'
          title_text = 'Ahh, a nice fresh note'
          body_text = "Can\'t wait to write in it!"
          fill_in('title-input', with: title_text)
          find('.wk-wysiwyg').set(body_text)
          find('.ple-publish').click()
        when 'question'
          visit '/questions/new?&tags=question%3Ageneral'
          title_text = "Let's talk condiments"
          body_text = 'Ketchup or mayo?'
          find("input[aria-label='Enter question']", match: :first)
            .click()
            .fill_in with: title_text
          find('.wk-wysiwyg').set(body_text)
          find('.ple-publish').click()
        when 'wiki'
          visit '/wiki/new'
          title_text = 'pokemon'
          body_text = 'Gotta catch em all!'
          fill_in('title', with: title_text)
          fill_in('text-input-main', with: body_text)
          find('#publish').click()
          visit "/wiki/#{title_text}/comments"
      end
      assert_selector('h1', text: title_text)
      page.find("textarea#text-input-main")
        .click
        .fill_in with: comment_text
      # preview comment
      find("#toggle-preview-button-main").click
      find("p", text: comment_text)
      # publish comment
      click_on "Publish"
      find(".noty_body", text: "Comment Added!")
      find("p", text: comment_text)
    end

    # Cross-Wiring Bugs

    # sometimes if edit and reply/main comment forms are open, 
    # you drop an image into edit form, and the link will end
    # up in the other one.

    # there are many variations of this bug. this particular test involves:
    #  DRAG & DROP upload into MAIN comment form
    #  DRAG & DROP into EDIT comment form (.dropzone button)
    test "#{page_type_string}: image DRAG & DROP into EDIT form isn't cross-wired with MAIN form" do
      # setup page with editable comment
      nodes(node_name).add_comment({
        uid: 2,
        body: comment_text
      })
      visit get_path(page_type, nodes(node_name).path)
      # .dropzone is hidden, so reveal it for Capybara's finders:
      Capybara.ignore_hidden_elements = false
      # drag & drop the image. drop_in_dropzone simulates 'drop' event, see application_system_test_case.rb
      drop_in_dropzone("#{Rails.root.to_s}/public/images/pl.png", '#comments-list + div .dropzone-large') # this CSS selects .dropzones that belong to sibling element immediately following #comments-list. technically, there are two .dropzones in the main comment form.
      Capybara.ignore_hidden_elements = true
      wait_for_ajax
      # we need the ID of parent div that contains <p>comment_text</p>:
      comment_id = page.find('p', text: comment_text).find(:xpath, '..')[:id]
      # regex to strip the ID number out of string. ID format is comment-body-4231
      comment_id_num = /comment-body-(\d+)/.match(comment_id)[1]
      comment_dropzone_selector = '#comment-form-body-edit-' + comment_id_num
      # open the edit comment form
      page.find(".edit-comment-btn").click
      # drop into the edit comment form
      Capybara.ignore_hidden_elements = false
      drop_in_dropzone("#{Rails.root.to_s}/public/images/pl.png", comment_dropzone_selector)
      Capybara.ignore_hidden_elements = true
      wait_for_ajax
      # open the preview for the main comment form
      page.find('#toggle-preview-button-main').click
      # once preview is open, the images are embedded in the page.
      # there should only be 1 image in the main comment form!
      preview_imgs = page.all('#comment-preview-main img').size
      assert_equal(1, preview_imgs)
    end

    # cross-wiring test: 
    # SELECT image upload in both:
    #   EDIT form
    #   MAIN form

    # NOTE: this is also a test for:
    #   IMMEDIATE image SELECT upload into MAIN comment form
    test "#{page_type_string}: image SELECT upload into EDIT form isn't CROSS-WIRED with MAIN form" do
      nodes(node_name).add_comment({
        uid: 5,
        body: comment_text
      })
      nodes(node_name).add_comment({
        uid: 2,
        body: comment_text
      })
      visit get_path(page_type, nodes(node_name).path)
      # open the edit comment form:
      find(".edit-comment-btn").click
      # find the parent of edit comment's fileinput:
      comment_fileinput_parent_id = page.find('[id^=dropzone-small-edit-]')[:id] # 'begins with' CSS selector
      comment_id_num = /dropzone-small-edit-(\d+)/.match(comment_fileinput_parent_id)[1]
      # upload images
      # the <inputs> that take image uploads are hidden, so reveal them:
      Capybara.ignore_hidden_elements = false
      # upload an image in the main comment form
      page.find('#fileinput-button-main').set("#{Rails.root.to_s}/public/images/pl.png")
      wait_for_ajax
      # find edit comment's fileinput:
      page.find('#fileinput-button-edit-' + comment_id_num).set("#{Rails.root.to_s}/public/images/pl.png")
      wait_for_ajax
      Capybara.ignore_hidden_elements = true
      # click preview buttons in main and edit form
      page.find('h4', text: /Post comment|Post Comment/) # title text on wikis is 'Post comment'
        .find(:xpath, '..')
        .find('a', text: 'Preview').click
      page.find('#comment-form-edit-' + comment_id_num + ' a', text: 'Preview').click
      # once preview is open, the images are embedded in the page.
      # there should be 1 image in main, and 1 image in edit
      assert_selector('#comment-preview-edit-' + comment_id_num + ' img', count: 1)
      assert_selector('#comment-preview-main img', count: 1)
    end

    # cross-wiring test
    # SELECT image upload in both:
    #   EDIT FORM
    #   REPLY form
    test "#{page_type_string}:  image SELECT upload into EDIT form isn't CROSS-WIRED with REPLY form" do
      nodes(node_name).add_comment({
        uid: 2,
        body: comment_text
      })
      visit get_path(page_type, nodes(node_name).path)
      # find the EDIT id
      # open up the edit comment form
      page.find(".edit-comment-btn").click
      edit_comment_form_id = page.find('h4', text: 'Edit comment').find(:xpath, '..')[:id]
      # regex to strip the ID number out of string. ID format is #c1234edit
      edit_id_num = /comment-form-edit-(\d+)/.match(edit_comment_form_id)[1]
      # open the edit comment form
      edit_preview_id = '#comment-preview-edit-' + edit_id_num
      # find the REPLY id
      page.all('p', text: 'Reply to this comment...')[0].click
      reply_dropzone_id = page.find('[id^=dropzone-small-reply-]')[:id]
      # ID begins with...
      reply_id_num = /dropzone-small-reply-(\d+)/.match(reply_dropzone_id)[1]
      # upload images
      # the <inputs> that take image uploads are hidden, so reveal them:
      Capybara.ignore_hidden_elements = false
      # upload an image in the reply comment form
      page.find('#fileinput-button-reply-' + reply_id_num).set("#{Rails.root.to_s}/public/images/pl.png")
      wait_for_ajax
      # upload an image in the edit comment form
      page.find('#fileinput-button-edit-' + edit_id_num).set("#{Rails.root.to_s}/public/images/pl.png")
      Capybara.ignore_hidden_elements = true
      wait_for_ajax
      # click preview buttons in reply and edit form
      page.find('#comment-form-edit-' + edit_id_num + ' a', text: 'Preview').click
      page.first('a', text: 'Preview').click
      assert_selector('#comment-preview-edit-' + edit_id_num + ' img', count: 1)
      assert_selector('#comment-preview-reply-' + reply_id_num, count: 1)
    end

    test "#{page_type_string}: rich-text input into REPLY form isn't CROSS-WIRED with EDIT form" do
      nodes(node_name).add_comment({
        uid: 5,
        body: comment_text
      })
      nodes(node_name).add_comment({
        uid: 2,
        body: comment_text
      })
      visit get_path(page_type, nodes(node_name).path)
      # open up the edit comment form
      page.find(".edit-comment-btn").click
      # find the EDIT id
      edit_comment_form_id = page.find('h4', text: 'Edit comment').find(:xpath, '..')[:id]
      # open up the reply comment form
      page.all('p', text: 'Reply to this comment...')[1].click
      page.all("[data-original-title='Bold']")[0].click
      reply_input_value = page.find('[id^=text-input-reply-]').value
      edit_input_value = page.find('#' + edit_comment_form_id + ' textarea').value
      assert_equal(comment_text, edit_input_value)
      assert_equal('****', reply_input_value)
    end
  end
end
