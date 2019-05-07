require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class PostTest < ApplicationSystemTestCase

  def setup
    activate_authlogic
  end

  test 'posting from the editor' do
    visit '/'

    click_on 'Login'
    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"

    visit '/post'

    fill_in("Title", with: "My new post", wait: 4)
    
    el = find(".wk-wysiwyg") # rich text input
    el.set("All about this interesting stuff")

    assert_page_reloads do

      find('.ple-publish').click
      assert_selector('h1', text: "My new post", wait: 4)
      assert_selector('#content', text: "All about this interesting stuff")
      assert_selector('.alert-success', text: "×\nSuccess! Thank you for contributing open research, and thanks for your patience while your post is approved by community moderators and we'll email you when it is published. In the meantime, if you have more to contribute, feel free to do so.")
      
    end

  end

  # Utility methods:
  
  def assert_page_reloads(message = "page should reload")
    page.evaluate_script "document.body.classList.add('not-reloaded')"
    yield
    if has_selector? "body.not-reloaded"
      assert false, message
    end
  end

  def assert_page_does_not_reload(message = "page should not reload")
    page.evaluate_script "document.body.classList.add('not-reloaded')"
    yield
    unless has_selector? "body.not-reloaded"
      assert false, message
    end
    page.evaluate_script "document.body.classList.remove('not-reloaded')"
  end
  
end

