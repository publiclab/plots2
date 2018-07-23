require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  test 'should not contains special characters in value' do
    image = images(:one)
    assert image.is_image?
    assert_equal "jpg", image.filetype
    assert_equal "/i/#{image.id}", image.shortlink
    assert_not_nil image.filename
    assert_not_nil image.filename
  end
end
