require "application_system_test_case"

class DashboardTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'viewing the dashboard' do
    visit '/'

    click_on 'Login'

    take_screenshot

    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"

    visit '/dashboard'

    assert_selector('.row .header h1', text: "Dashboard")
    assert_selector('#activity-header > i', text: "Activity")

    take_screenshot

  end
  
  test "User can flag a node from dashboard" do
    visit '/'
    click_on 'Login'
    node = Node.where(status: 1)
      .order(nid: :desc)
      .first
    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"
    visit '/dashboard'
    find("#flag_node#{node.id}").click()
    assert find("div.alert", text: "Node flagged.")
  end
end
