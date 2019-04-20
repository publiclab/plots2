require "application_system_test_case"

class PlaceTagsTest < ApplicationSystemTestCase

  # node blog has lat and lon tag and place tag .	
  test "pages tagged with place get a full-width map across the top of the page" do
    visit nodes(:blog).path
    assert_selector('h1', text: 'Blog post')
    assert_selector('div#top_map')
  end

  # node map has lat and lon tag but no place tag .
  test "pages not tagged with place gets a side map" do
    visit nodes(:map).path
    assert_select "div#top_map" , :count => 0 
  end

end
