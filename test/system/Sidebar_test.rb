require "application_system_test_case"

class SidebarTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'viewing the sidebar' do
    visit node(:about).path

    click_on '#ellipsis_sidebar'

    assert_selector('.dropdowna .dropdown-menu .dropdown-item a', text: "Users who liked this")

    take_screenshot

  end

end
