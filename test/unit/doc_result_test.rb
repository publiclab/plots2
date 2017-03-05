require 'test_helper'

class DocResultTest < ActiveSupport::TestCase

  test "should return fromSearch" do
    node1 = node(:question)
    obj = DocResult.fromSearch(
             node1.nid,
             'note',
             node1.path,
             node1.title,
             '',
             0
    )
    assert_equal node1.nid,   obj.docId
    assert_equal 'note',     obj.docType
    assert_equal node1.path,  obj.docUrl
    assert_equal node1.title, obj.docTitle
    assert_equal '',         obj.docSummary
    assert_equal 0,          obj.docScore
  end

end
