require "application_system_test_case"

class TagTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'viewing the dropdown menu' do
    visit '/tag/test'

    take_screenshot

    click_on "by type"

    take_screenshot

  end

end
