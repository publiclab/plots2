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

  test "tag weekly tallies" do
    tag = tags(:awesome)
    tallies = tag.weekly_tallies
    assert_equal 52, tallies.length
    assert_not_nil tallies[51]
    assert_not_equal [], tallies[51]
    assert_equal 1, tallies[51]
  end

  test "tag nodes_in_week" do
    nodes_in_week = DrupalTag.nodes_for_period(
      'note', 
      [ node(:one).nid ],
      (Time.now.to_i - 1.weeks.to_i).to_s,
      (Time.now.to_i).to_s
    )
    assert_not_nil nodes_in_week
    assert nodes_in_week.length > 0

    nodes_in_year = DrupalTag.nodes_for_period(
      'note', 
      [ node(:one).nid ],
      (Time.now.to_i - 52.weeks.to_i).to_s,
      (Time.now.to_i).to_s
    )
    assert_not_nil nodes_in_year
    assert nodes_in_year.length > 0
  end

end
