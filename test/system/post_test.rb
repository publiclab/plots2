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

    fill_in("Title", with: "My new post")
    
    el = find(".wk-wysiwyg") # rich text input
    el.set("All about this interesting stuff")

    find('.ple-publish').click
    # find('.ple-publish').click # may have to do it twice if it prompts for an image

    assert_response :redirect
    follow_redirect!

    assert_selector('h1', text: 'My new post')
    assert_selector('#content', text: "All about this interesting stuff")
    assert_selector('#notice', 'User was successfully created.')
  end
  
end
