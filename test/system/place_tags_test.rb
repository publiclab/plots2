require "application_system_test_case"

class PlaceTagsTest < ApplicationSystemTestCase

  # node blog has lat and lon tag and place tag .	
  test "pages tagged with place get a full-width map across the top of the page" do
    visit nodes(:blog).path
    assert_selector('h1', text: 'Blog post')
    assert_selector('div#top_map')
    assert_selector('div.leaflet-layer')
  end

  # one map has no place tag .
  test "pages not tagged with place gets a side map" do
    visit nodes(:one).path
    assert_selector('h1', text: 'Canon A1200 IR conversion at PLOTS Barnraising at LUMCON')
    assert_selector('div.leaflet-layer' , count: 0)
  end

end
