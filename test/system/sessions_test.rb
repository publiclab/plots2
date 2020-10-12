require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase

  test 'return_to query parameter preserved while switching from /login to /signup' do
    visit '/login?return_to=page'
    click_on 'sign up'

    path = URI.parse(current_url).request_uri
    assert_equal path, '/signup?return_to=page'
  end

  test 'the user after login is redirected to the note he was trying to comment' do
    visit '/wiki/wiki-page-path/comments'

    find('a[data-target="#loginModal"]', text: 'Login').click()

    fill_in 'user_session[username]', with: 'jeff'
    fill_in 'user_session[password]', with: 'secretive'

    click_on 'Log in'

    path = URI.parse(current_url).request_uri
    assert_equal path, '/wiki/wiki-page-path/comments'
  end

end