require "application_system_test_case"

class TagTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'viewing the dropdown menu' do
    visit '/tag/test'

    take_screenshot

    find("#dropdownMenuButton", text: "by type", match: :first).click()

    take_screenshot

  end

end
