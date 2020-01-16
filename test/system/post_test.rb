require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class PostTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper
  Capybara.default_max_wait_time = 60

  test 'posting from the editor' do
    visit '/'

    click_on 'Login'
    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"

    visit '/post'

    fill_in("title-input", with: "My new post")
    
    el = find(".wk-wysiwyg") # rich text input
    el.set("All about this interesting stuff")

    assert_page_reloads do

      find('.ple-publish').click
      assert_selector('h1', text: "My new post")
      assert_selector('#content', text: "All about this interesting stuff")
      assert_selector('.alert-success', text: "×\nSuccess! Thank you for contributing open research, and thanks for your patience while your post is approved by community moderators and we'll email you when it is published. In the meantime, if you have more to contribute, feel free to do so.")
      
    end

  end

  test 'adding tags to the post' do
    visit '/wiki/wiki-page-path/comments'

    find('a[data-target="#loginModal"]', text: 'Login').click()

    fill_in 'user_session[username]', with: 'jeff'
    fill_in 'user_session[password]', with: 'secretive'

    click_on 'Log in'

    find('a#tags-open').click()

    find('.tag-input').set('nature').native.send_keys(:return)
    find('.tag-input').set('mountains').native.send_keys(:return)

    # Make sure that the 2 tags are added
    page.assert_selector('.tags-list p.badge', :count => 2)
  end

  test 'removing tags from the post' do
    visit '/wiki/wiki-page-path/comments'

    find('a[data-target="#loginModal"]', text: 'Login').click()

    fill_in 'user_session[username]', with: 'jeff'
    fill_in 'user_session[password]', with: 'secretive'

    click_on 'Log in'

    find('a#tags-open').click()

    find('.tag-input').set('nature').native.send_keys(:return)
    find('.tag-input').set('mountains').native.send_keys(:return)

    find('.tags-list p.badge .tag-delete').click()
    find('.tags-list p.badge .tag-delete').click()

    # Make sure that the 2 tags are removed
    page.assert_selector('.tags-list p.badge', :count => 0)
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

