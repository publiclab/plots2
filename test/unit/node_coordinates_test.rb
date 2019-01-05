require 'test_helper'

class NodeCoordinatesTest < ActiveSupport::TestCase

  test 'adding latitude to node' do
    node = nodes(:one)

    # test node.add_tag, which is used to add lat/lon tags and update latitude, longitude and precision
    # columns in node table
    saved, tag, table_updated = node.add_tag('lat:10.0002', users(:bob))
    assert saved
    assert_not_nil tag
    assert table_updated
    assert_equal node.precision, 4
    assert_equal node.latitude, 10.0002
  end

  test 'adding longitude to node' do
    node = nodes(:one)

    # test node.add_tag, which is used to add lat/lon tags and update latitude, longitude and precision
    # columns in node table
    saved, tag, table_updated = node.add_tag('lon:-9.0002', users(:bob))
    assert saved
    assert_not_nil tag
    assert table_updated
    assert_equal node.longitude, -9.0002
  end
end
