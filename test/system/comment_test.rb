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

  test 'comment image drag and drop upload' do
    Capybara.ignore_hidden_elements = false
    visit "/wiki/wiki-page-path/comments"

    find("p", text: "Reply to this comment...").click()

    reply_preview_button = page.all('#post_comment')[0]

    # Upload the image
    drop_in_dropzone("#{Rails.root.to_s}/public/images/pl.png")

    # Wait for image upload to finish
    wait_for_ajax
    Capybara.ignore_hidden_elements = true

    # Toggle preview
    reply_preview_button.click()

    # Make sure that image has been uploaded
    page.assert_selector('#preview img', count: 1)
  end


  # https://web.archive.org/web/20170730200309/http://blog.paulrugelhiatt.com/rails/testing/capybara/dropzonejs/2014/12/29/test-dropzonejs-file-uploads-with-capybara.html
  def drop_in_dropzone(file_path)
    # Generate a fake input element
    page.execute_script <<-JS
      fakeFileInput = window.$('<input/>').attr(
        {id: 'fakeFileInput', type:'file'}
      ).appendTo('body');
    JS

    # Attach the file to the fake input element
    attach_file("fakeFileInput", file_path)

    page.execute_script <<-JS
      var dataTransfer = new DataTransfer()
      dataTransfer.items.add(fakeFileInput.get(0).files[0])

      var fakeDropEvent = new DragEvent('drop')
      var fileToDrop = fakeFileInput.get(0).files[0]

      // Generate the fake "drop" event
      Object.defineProperty(fakeDropEvent, 'dataTransfer', {
        value: new FakeDataTransferObject(fileToDrop)
      });

      var dropzoneArea = document.querySelector('.dropzone');
      // Transfer the image to the dropzone area
      dropzoneArea.files = dataTransfer.files;
      // Emit the fake "drop" event
      dropzoneArea.dispatchEvent(fakeDropEvent);

      // Generate fake data transfer object
      function FakeDataTransferObject(file) {
        this.dropEffect = 'all';
        this.effectAllowed = 'all';
        this.items = [];
        this.types = ['Files'];
        this.getData = function() {
          return file;
        };
        this.files = [file];
      };
    JS
  end

  # https://stackoverflow.com/questions/36536111/waiting-for-ajax-with-capybara-poltergeist
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
      request_count = page.evaluate_script("$.active").to_i
      request_count && request_count.zero?
    rescue Timeout::Error
  end

end
