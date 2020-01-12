require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase

  test 'return_to query parameter preserved while switching from /login to /signup' do
    visit '/login?return_to=page'
    click_on 'sign up'

    path = URI.parse(current_url).request_uri
    assert_equal path, '/signup?return_to=page'
  end

end