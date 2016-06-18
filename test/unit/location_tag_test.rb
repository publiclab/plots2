require 'test_helper'

class LocationTagTest < ActiveSupport::TestCase

  test "should create LocationTag" do
    user = rusers(:jeff)
    location_tag = LocationTag.new({
      uid: user.id,
      location: "New York, NY, United States",
      lat: 40.712784,
      long: -74.005941,
      city: "New York",
      state: "NY",
      country: "United States"
    })

    assert location_tag.save
    assert_not_nil location_tag.location
    assert_not_nil location_tag.lat
    assert_not_nil location_tag.long
    assert_not_nil location_tag.country
    assert_not_nil location_tag.city
    assert_not_nil location_tag.state
  end
end
