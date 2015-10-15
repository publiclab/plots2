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

  test "should scan multiple callouts out of body" do
    comment = DrupalComment.new({
      nid: node(:one).nid,
      uid: rusers(:bob).id
    })
    comment.comment = 'Hey, @bob, @jeff, @bob, what do you think?'
    assert_equal comment.mentioned_users.length, 2 # one duplicate, removed
    assert_equal comment.mentioned_users.first.id, rusers(:bob).id
    assert_equal comment.mentioned_users[1].id, rusers(:jeff).id
  end

  test "should scan multiple space-separated callouts out of body" do
    comment = DrupalComment.new({
      nid: node(:one).nid,
      uid: rusers(:bob).id
    })
    comment.comment = 'Hey, @bob @jeff @bob, what do you think?'
    assert_equal comment.mentioned_users.length, 2 # one duplicate, removed
    assert_equal comment.mentioned_users[0].id, rusers(:bob).id
    assert_equal comment.mentioned_users[1].id, rusers(:jeff).id
  end

end
