require 'test_helper'
class UserTest < ActiveSupport::TestCase
  test "users who do not follow tags" do
    node = Node.new
    assert_empty node.tags

    node = Node.find(1)
    assert_not_empty node.tags

    node = Node.all
    node_tags = Node.all { |i| i.tags  }
    assert node.count == node_tags.count

    tag = Tag.new
    assert_empty tag.subscriptions

    tag_subscriptions = Tag.all.each { |tag| tag.subscriptions.pluck :user_id }
    tag_users_by_id =  tag_subscriptions.map {|id| User.find_by_id id}
    assert tag_subscriptions.count == tag_users_by_id.count
  end
end
