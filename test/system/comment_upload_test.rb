require "application_system_test_case"

class CommentUploadTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test "uploading by dragging" do
    # log in
    visit '/'
    click_on 'Login'
    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"

    visit Node.last.path

    assert_selector('h1', text: Node.last.title) # this should also wait for everything to load
    drop_in_dropzone("#{Rails.root.to_s}/public/images/pl.png", false)
    click_button 'Publish'
    expect(page.find('#comments .comment image')['src']).to match('test.png')
  end

  # Utility methods:

# https://web.archive.org/web/20170730200309/http://blog.paulrugelhiatt.com/rails/testing/capybara/dropzonejs/2014/12/29/test-dropzonejs-file-uploads-with-capybara.html
def drop_in_dropzone(file_path, visible = false)
    # Generate a fake input selector
    page.execute_script <<-JS
      fakeFileInput = window.$('<input/>').attr(
        {id: 'fakeFileInput', type:'file'}
      ).appendTo('body');
    JS
    # Attach the file to the fake input selector with Capybara
    attach_file("fakeFileInput", file_path, visible: visible)
    page.execute_script <<-JS
      (function(){ // use closure to bump execution to end of pageload
        var fileList = [fakeFileInput.get(0).files[0]] // Add the file to a fileList array
        var e = jQuery.Event('drop', { dataTransfer : { files : fileList } });
        $('.dropzone')[0].dropzone.listeners[0].events.drop(e); // Trigger the fake drop event
      })()
    JS
  end
  
end
