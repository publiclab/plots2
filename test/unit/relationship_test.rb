require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  
  def setup
    follower_user = users(:bob)
    followed_user = users(:jeff)
    @relationship = Relationship.new(followed_id: followed_user.uid, follower_id: follower_user.uid)
  end

  test "should be valid" do
    assert @relationship.valid?
  end

  test "should require follower_id" do
    @relationship.follower_id = nil
    assert @relationship.valid?
  end

  test "should require followed_id" do
    @relationship.followed_id = nil
    assert @relationship.valid?
  end
end
