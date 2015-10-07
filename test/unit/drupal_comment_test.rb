require 'test_helper'

class DrupalCommentTest < ActiveSupport::TestCase

  test "should not save comment without body" do
    comment = DrupalComment.new
    assert !comment.save, "Saved the comment without body text"
  end

  test "should scan callouts out of body" do
    comment = DrupalComment.new({
      nid: node(:one).nid,
      uid: rusers(:bob).id
    })
    comment.comment = 'Hey, @bob, what do you think?'
    assert_equal comment.mentioned_users.first.id, rusers(:bob).id
  end

end
