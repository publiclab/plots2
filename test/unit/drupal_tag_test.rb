require 'test_helper'

class TagTest < ActiveSupport::TestCase

  test "create a tag" do
    tag = Tag.new({
      name: "stick-mapping",
    })
    assert tag.save!
  end

  test "tag nodes" do
    tag = tags(:awesome)
    assert_not_nil tag.nodes
  end

  test "tag followers" do
    followers = Tag.followers(community_tags(:awesome).name)
    assert followers.length > 0
    assert followers.include?(tag_selection(:awesome).user.user)
  end

  test "tag subscribers" do
    subscribers = Tag.subscribers([tags(:awesome)])
    assert subscribers.length > 0
    assert (subscribers.to_a.collect(&:last).map { |o| o[:user]}).include?(tag_selection(:awesome).user)
  end

  test "creating a tag with a bad uid" do
    community_tag = DrupalNodeCommunityTag.new({
      uid: 1343151513,
      tid: tags(:awesome).tid,
      nid: node(:one).nid
    })
    assert community_tag.save!
    assert_nil community_tag.author
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
    nodes_in_week = Tag.nodes_for_period(
      'note', 
      [ node(:one).nid ],
      (Time.now.to_i - 1.weeks.to_i).to_s,
      (Time.now.to_i).to_s
    )
    assert_not_nil nodes_in_week
    assert nodes_in_week.length > 0

    nodes_in_year = Tag.nodes_for_period(
      'note', 
      [ node(:one).nid ],
      (Time.now.to_i - 52.weeks.to_i).to_s,
      (Time.now.to_i).to_s
    )
    assert_not_nil nodes_in_year
    assert nodes_in_year.length > 0
  end

  test "find all tagged research notes with status 1" do
    tagnames = ["test"]
    notes = Tag.find_research_notes(tagnames)
    expected = [node(:one)]
    assert_equal expected, notes
  end

  test "response power tagging" do
    tag = Tag.new({
      name: "response:#{node(:blog).id}"
    })
    assert tag.save!
    community_tag = DrupalNodeCommunityTag.new(
      tid: tag.tid,
      nid: node(:one).nid,
      uid: rusers(:bob).uid
    )
    assert community_tag.save!
    assert node(:blog).responses.length > 0
    assert node(:blog).response_count > 0
  end

  test "response power tagging with custom key" do
    tag = Tag.new({
      name: "replication:#{node(:blog).id}"
    })
    assert tag.save!
    community_tag = DrupalNodeCommunityTag.new(
      tid: tag.tid,
      nid: node(:one).nid,
      uid: rusers(:bob).uid
    )
    assert community_tag.save!
    assert node(:blog).responses('replication').length > 0
    assert node(:blog).response_count('replication') > 0
  end
end
