require "application_system_test_case"

class DashboardV2Test < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'trending tags are returned when a user has not subscribed to any topics' do
    visit '/'
    click_on 'Login'
    fill_in("username-login", with: "user_without_subscriptions")
    fill_in("password-signup", with: "secretive")
    click_on 'Log in'
    visit '/v2/dashboard'
    # Ensure that at least one trending tag is present on the trending and follow section
    assert_selector("div > div.other-topics > span a")
    assert_selector("div#moreTopics div > div > div a")
  end
end