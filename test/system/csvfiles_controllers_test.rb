require "application_system_test_case"

class CsvfilesControllersTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'simple-data-grapher powertag' do
    visit '/post?body=[simple-data-grapher:i/2/6]'

    take_screenshot
  end

  test 'visit simple-data-grapher' do
    visit '/graph'
    
    main_heading = find(".main_heading_container .main_heading", match: :first).text
    assert_equal "Simple Data Grapher", main_heading
  end
end
