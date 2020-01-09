require "application_system_test_case"

class MapTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper
  Capybara.default_max_wait_time = 120

  test 'correct url hash for wiki map' do
    visit '/map/chicago'

    # check that the url hash is correct
    # assert_equal("#13/41.87/-87.64", page.evaluate_script("window.location.hash"))
    assert_equal("/map#13/41.87/-87.64", page.current_path)

    
  end

  # test 'show map by hash location' do
  #   visit '/map#9/-25/-13'

  #   assert_equal(-25, page.evaluate_script("Math.round(map.getCenter().lat)"))
  #   assert_equal(-13, page.evaluate_script("Math.round(map.getCenter().lng)"))
  #   assert_equal(9, page.evaluate_script("map.getZoom()"))

  # end

  # test 'url hash updates when map panned' do
  #   visit '/map'

  #   page.execute_script("map.setView([13, 60], 15)")

  #   # check that the url hash is correct
  #   assert_equal("#15/13/60", page.evaluate_script("window.location.hash"))
    
  # end

end
