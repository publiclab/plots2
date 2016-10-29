require 'test_helper'

class DocResultTest < ActiveSupport::TestCase

  test "should return fromSearch" do
    node = node(:question)
    obj = DocResult.fromSearch(
             node.nid,
             'note',
             node.path,
             node.title,
             '',
             0
    )
    assert_equal node.nid,   obj.docId
    assert_equal 'note',     obj.docType
    assert_equal node.path,  obj.docUrl
    assert_equal node.title, obj.docTitle
    assert_equal '',         obj.docSummary
    assert_equal 0,          obj.docScore
  end

end
