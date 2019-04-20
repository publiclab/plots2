require "application_system_test_case"

class PlaceTagsTest < ApplicationSystemTestCase

  test "pages tagged with place get a full-width map across the top of the page" do
    visit nodes(:blog).path
    assert_select "div#top_map"
    assert_select "div.leaflet-layer"
  end

end
