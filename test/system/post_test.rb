require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class PostTest < ApplicationSystemTestCase

  test 'posting from the editor' do
    UserSession.create(users(:bob)) # log in

    visit '/post'

    fill_in("input#title-input", with: "My new post")
    fill_in("textarea#text-input", with: "All about this interesting stuff")

    find('.ple-publish').click

    assert_response :redirect
    follow_redirect!

    assert_selector('h1', text: 'My new post')
    assert_selector('#notice', 'User was successfully created.')
  end
  
end
