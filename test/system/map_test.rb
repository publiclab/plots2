require 'test_helper'
require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class MapTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  # test 'show map for wiki with location' do

  #   visit "/map/chicago"

  #   assert_equal("41.87", page.evaluate_script("map.getCenter().lat.toFixed(2)"))
  #   assert_equal("-87.64", page.evaluate_script("map.getCenter().lng.toFixed(2)"))
  #   assert_equal(13, page.evaluate_script("map.getZoom()"))

  # end

  # test 'show map for wiki without location' do
  #   visit '/'

  #   click_on 'Login'

  #   fill_in("username-login", with: "jeff")
  #   fill_in("password-signup", with: "secretive")
  #   click_on "Log in"

  #   visit "/map/organizers"

  #   # check that the map is correctly centered - should show user's location
  #   assert_equal(59, page.evaluate_script("Math.round(map.getCenter().lat)"))
  #   assert_equal(0, page.evaluate_script("Math.round(map.getCenter().lng)"))
  #   assert_equal(10, page.evaluate_script("map.getZoom()"))

  # end

  test 'correct url hash for wiki map' do
    visit '/map/chicago'

    # check that the url hash is correct
    assert_equal("#13/41.87/-87.64", page.evaluate_script("window.location.hash"))
    
  end

  test 'show map by hash location' do
    visit '/map#9/-25/-13'

    assert_equal(-25, page.evaluate_script("Math.round(map.getCenter().lat)"))
    assert_equal(-13, page.evaluate_script("Math.round(map.getCenter().lng)"))
    assert_equal(9, page.evaluate_script("map.getZoom()"))

  end

  test 'url hash updates when map panned' do
    visit '/map'

    page.execute_script("map.setView([13, 60], 15)")

    # check that the url hash is correct
    assert_equal("#15/13/60", page.evaluate_script("window.location.hash"))
    
  end

end
