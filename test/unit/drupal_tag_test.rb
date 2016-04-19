require 'test_helper'

class DrupalTagTest < ActiveSupport::TestCase

  test "create a tag" do
    tag = DrupalTag.new({
      name: "stick-mapping",
    })
    assert tag.save!
  end

  test "tag nodes" do
    tag = tags(:awesome)
    assert_not_nil tag.nodes
  end

  test "tag followers" do
    followers = DrupalTag.followers(community_tags(:awesome).name)
    assert followers.length > 0
    assert followers.include?(tag_selection(:awesome).user.user)
  end

  test "tag subscribers" do
    subscribers = DrupalTag.subscribers([tags(:awesome)])
    assert subscribers.length > 0
    assert (subscribers.to_a.collect(&:last).map { |o| o[:user]}).include?(tag_selection(:awesome).user)
  end

end
