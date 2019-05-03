require "application_system_test_case"

class CommentUploadTest < ApplicationSystemTestCase

  test "uploading by dragging" do
    # log in
    visit '/'
    click_on 'Login'
    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"

    visit Node.last.path
    drop_in_dropzone 'public/images/pl.png'
    click_button 'Publish'
    expect(page.find('#comments .comment image')['src']).to match('test.png')
  end

  # Utility methods:

# https://web.archive.org/web/20170730200309/http://blog.paulrugelhiatt.com/rails/testing/capybara/dropzonejs/2014/12/29/test-dropzonejs-file-uploads-with-capybara.html
def drop_in_dropzone(file_path)
    # Generate a fake input selector
    page.execute_script <<-JS
      fakeFileInput = window.$('<input/>').attr(
        {id: 'fakeFileInput', type:'file'}
      ).appendTo('body');
    JS
    # Attach the file to the fake input selector with Capybara
    attach_file("fakeFileInput", file_path)
    # Add the file to a fileList array
    page.execute_script("var fileList = [fakeFileInput.get(0).files[0]]")
    # Trigger the fake drop event
    page.execute_script <<-JS
      var e = jQuery.Event('drop', { dataTransfer : { files : fileList } });
      $('.dropzone')[0].dropzone.listeners[0].events.drop(e);
    JS
  end
  
end
