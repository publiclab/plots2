require 'test_helper'

class TagTest < ActiveSupport::TestCase
  test 'create a tag' do
    tag = Tag.new(name: 'stick-mapping')
    assert tag.save!
  end

  test 'tag nodes' do
    tag = tags(:awesome)
    assert_not_nil tag.nodes
  end

  test 'tag followers' do
    followers = Tag.followers(community_tags(:awesome).name)
    assert !followers.empty?
    assert followers.include?(tag_selection(:awesome).user.user)
  end

  test 'tag subscribers' do
    subscribers = Tag.subscribers([tags(:awesome)])
    assert !subscribers.empty?
    assert (subscribers.to_a.collect(&:last).map { |o| o[:user] }).include?(tag_selection(:awesome).user)
  end

  test 'creating a tag with a bad uid' do
    community_tag = NodeTag.new(uid: 1_343_151_513,
                                               tid: tags(:awesome).tid,
                                               nid: node(:one).nid)
    assert community_tag.save!
    assert_nil community_tag.author
  end

  test 'tag weekly tallies' do
    tag = tags(:awesome)
    tallies = tag.weekly_tallies
    assert_equal 52, tallies.length
    assert_not_nil tallies[51]
    assert_not_equal [], tallies[51]
    assert_equal 1, tallies[51]
  end

  test 'tag nodes_in_week' do
    nodes_in_week = Tag.nodes_for_period(
      'note',
      [node(:one).nid],
      (Time.now.to_i - 1.weeks.to_i).to_s,
      Time.now.to_i.to_s
    )
    assert_not_nil nodes_in_week
    assert !nodes_in_week.empty?

    nodes_in_year = Tag.nodes_for_period(
      'note',
      [node(:one).nid],
      (Time.now.to_i - 52.weeks.to_i).to_s,
      Time.now.to_i.to_s
    )
    assert_not_nil nodes_in_year
    assert !nodes_in_year.empty?
  end

  test 'find all tagged research notes with status 1' do
    tagnames = ['test']
    notes = Tag.find_research_notes(tagnames)
    expected = [node(:one)]
    assert_equal expected, notes
  end

  test 'response power tagging' do
    tag = Tag.new(name: "response:#{node(:blog).id}")
    assert tag.save!
    community_tag = NodeTag.new(
      tid: tag.tid,
      nid: node(:one).nid,
      uid: rusers(:bob).uid
    )
    assert community_tag.save!
    assert !node(:blog).responses.empty?
    assert node(:blog).response_count > 0
  end

  test 'response power tagging with custom key' do
    tag = Tag.new(name: "replication:#{node(:blog).id}")
    assert tag.save!
    community_tag = NodeTag.new(
      tid: tag.tid,
      nid: node(:one).nid,
      uid: rusers(:bob).uid
    )
    assert community_tag.save!
    assert !node(:blog).responses('replication').empty?
    assert node(:blog).response_count('replication') > 0
  end

  test "returns empty array if users are  following both the given tags and this tag" do
    tag = tags(:spam)
    given_tags = [tags(:chapter)]
    assert_equal [], tag.followers_who_dont_follow_tags(given_tags)
  end

  test " returns users following this tags but not given tags" do
    # users following tag are bob, unbanned_spammer, admin
    # users following tag1 are bob, admin, obiwan
    # users following tag2 are spammer, newcomer
    tag = tags(:test)
    tag1 = tags(:awesome)
    tag2 = tags(:spam)
    given_tags = [tag1, tag2]
    assert_equal [rusers(:admin)], tag.followers_who_dont_follow_tags(given_tags)
  end

  test 'returns all users in this tag if none is following the given tags' do
    tag = tags(:spam)
    tag2 = tags(:test)
    tag1 = tags(:awesome)
    given_tags = [tag1, tag2]
    assert_equal [rusers(:spammer), rusers(:newcomer)], tag.followers_who_dont_follow_tags(given_tags).sort
  end
end
