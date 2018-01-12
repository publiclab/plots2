require 'test_helper'

class TagResultTest < ActiveSupport::TestCase
  test 'should return fromSearch' do
    node = nodes(:question)
    obj = TagResult.fromSearch(
      node.nid,
      node.title,
      'question-circle',
      node.path
    )
    assert_equal node.nid,          obj.tagId
    assert_equal node.title,        obj.tagVal
    assert_equal 'question-circle', obj.tagType
    assert_equal node.path,         obj.tagSource
  end
end
