require "application_system_test_case"

class ScreenshotsTest < ApplicationSystemTestCase
  test 'front page with navbar search autocomplete' do
    visit '/'

    fill_in("searchform_input", with: "Canon")
    
    assert_selector ".typeahead li", text: "Canon A1200 IR conversion at PLOTS Barnraising at LUMCON", wait: 10

    take_screenshot
  end
end
