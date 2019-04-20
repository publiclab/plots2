require "application_system_test_case"

class PlaceTagsTest < ApplicationSystemTestCase

  test "pages tagged with place get a full-width map across the top of the page" do
    visit nodes(:map).path
    assert_select "div.leaflet-layer"
    assert_select "div#top_map"
  end

  test "pages not tagged with place ges a side map" do
    visit nodes(:map).path
    assert_select "div#top_map" , :count => 0 
  end

end
