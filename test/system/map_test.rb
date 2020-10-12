require 'test_helper'
require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class MapTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'correct url hash for wiki map' do
    visit '/map/chicago'

    url_hash = page.evaluate_script("window.location.hash")

    # Wait for any potential asynchronous operations to complete
    wait_for_ajax

    # check that the url hash is correct
    assert_equal("#13/41.87/-87.64", url_hash)
  end

  test 'show map by hash location' do
    visit '/map#9/-25/-13'

    lat = page.evaluate_script("Math.round(map.getCenter().lat)")
    lng = page.evaluate_script("Math.round(map.getCenter().lng)")
    zoom = page.evaluate_script("map.getZoom()")

    # Wait for any potential asynchronous operations to complete
    wait_for_ajax

    assert_equal(-25, lat)
    assert_equal(-13, lng)
    assert_equal(9, zoom)
  end

  test 'url hash updates when map panned' do
    visit '/map'

    page.execute_script("map.setView([13, 60], 15)")
    url_hash = page.evaluate_script("window.location.hash")

    # check that the url hash is correct
    assert_equal("#15/13/60", url_hash)
  end

end
