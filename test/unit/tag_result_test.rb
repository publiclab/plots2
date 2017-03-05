require 'test_helper'

class TagResultTest < ActiveSupport::TestCase

  test "should return fromSearch" do
    node1 = node(:question)
    obj = TagResult.fromSearch(
             node1.nid,
             node1.title,
             "question-circle",
             node1.path
    )
    assert_equal node1.nid,          obj.tagId
    assert_equal node1.title,        obj.tagVal
    assert_equal "question-circle", obj.tagType
    assert_equal node1.path,         obj.tagSource
  end

end
