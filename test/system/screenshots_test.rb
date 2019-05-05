require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class ScreenshotsTest < ApplicationSystemTestCase
  test 'front page with navbar search autocomplete' do
    visit '/'

    fill_in("searchform_input", with: "Canon")

    take_screenshot # remove this later
    # we set RAILS_SYSTEM_TESTING_SCREENSHOT to 'inline', could be 'artifact' too... see Rails API guide
    
    assert_selector ".typeahead li", text: "Canon A1200 IR conversion at PLOTS Barnraising at LUMCON", wait: 10

    take_screenshot
  end
end
