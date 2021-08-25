require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  test 'should not contains special characters in value' do
    image = images(:one)
    assert image.is_image?
    assert_not_nil image.path
    assert_not_nil image.path(:original)
    assert_equal "jpg", image.filetype
    assert_equal "/i/#{image.id}", image.shortlink
    assert_not_nil image.filename
    assert_not_nil image.filename
  end

  test 'upload via datauri/dataurl' do
    image = Image.new({
      photo_file_name: 'datauri',
      photo: "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAAQABADASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAf/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAABgj/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABykX//Z",
      uid: 1})
    assert image.save
  end
end
