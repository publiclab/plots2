require 'test_helper'

class TagTest < ActiveSupport::TestCase
  def setup
    @start = (Date.today - 1.year).to_time
    @fin = Date.today.to_time
  end
  test 'create a tag' do
    tag = Tag.new(name: 'stick-mapping')
    assert tag.save!
    assert tag.nid
    assert tag.id
    assert_equal "/tag/stick-mapping", tag.path
    assert_equal "stick-mapping", tag.title
  end

  test 'tag nodes' do
    tag = tags(:awesome)
    assert_not_nil tag.nodes
  end

  test 'tag counting' do
    tag = tags(:awesome)
    assert_nil tag.count
    assert_not_nil tag.run_count
    assert_not_nil tag.count
    assert_equal 3, tag.count

    tag = tags(:spam)
    assert_nil tag.count
    assert_not_nil tag.run_count
    assert_not_nil tag.count
    assert_equal 0, tag.count # even if used, it should not count spam tags
  end

  test 'tag followers' do
    followers = Tag.followers(node_tags(:awesome).name)
    assert followers.any?
    assert followers.include?(tag_selections(:awesome).user)
  end

  test 'related tags does not include spam' do
    awesome_tag = tags(:awesome)
    spam_node = nodes(:spam)
    spam_node.tags << awesome_tag
    related = Tag.related(awesome_tag.name)
    assert related.any?
    assert related.include?(tags(:test))
    refute related.include?(tags(:spam))
  end

  test 'tag subscribers' do
    subscribers = Tag.subscribers([tags(:awesome)])
    assert subscribers.any?
    assert (subscribers.to_a.collect(&:last).map { |o| o[:user] }).include?(tag_selections(:awesome).user)
  end

  test 'creating a tag with a bad uid' do
    node_tag = NodeTag.new(uid: 1_343_151_513,
                                               tid: tags(:awesome).tid,
                                               nid: nodes(:one).nid)
    assert node_tag.save!
    assert_raises(ActiveRecord::RecordNotFound) do
      node_tag.author
    end
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
      [nodes(:one).nid],
      (Time.now.to_i - 1.weeks.to_i).to_s,
      Time.now.to_i.to_s
    )
    assert_not_nil nodes_in_week
    assert nodes_in_week.any?

    nodes_in_year = Tag.nodes_for_period(
      'note',
      [nodes(:one).nid],
      (Time.now.to_i - 52.weeks.to_i).to_s,
      Time.now.to_i.to_s
    )
    assert_not_nil nodes_in_year
    assert nodes_in_year.any?
  end

  test 'find all tagged research notes with status 1' do
    tagnames = ['test']
    notes = Tag.find_research_notes(tagnames)
    expected = [nodes(:one)]
    assert_equal expected, notes
  end

  test 'response power tagging' do
    tag = Tag.new(name: "response:#{nodes(:blog).id}")
    assert tag.save!
    node_tag = NodeTag.new(
      tid: tag.tid,
      nid: nodes(:one).nid,
      uid: users(:bob).uid
    )
    assert node_tag.save!
    assert nodes(:blog).responses.any?
    assert nodes(:blog).response_count > 0
  end

  test 'response power tagging with custom key' do
    tag = Tag.new(name: "replication:#{nodes(:blog).id}")
    assert tag.save!
    node_tag = NodeTag.new(
      tid: tag.tid,
      nid: nodes(:one).nid,
      uid: users(:bob).uid
    )
    assert node_tag.save!
    assert nodes(:blog).responses('replication').any?
    assert nodes(:blog).response_count('replication') > 0
  end

  test "returns empty array if users are  following both the given tags and this tag" do
    tag = tags(:spam)
    given_tags = [tags(:chapter)]
    assert_equal [], tag.followers_who_dont_follow_tags(given_tags)
  end

  test " returns users following this tags but not given tags" do
    test = tags(:test)       # users following tag are bob, unbanned_spammer, admin, and following: false for jeff
    awesome = tags(:awesome) # users following tag1 are bob, unbanned_spammer, moderator
    spam = tags(:spam)       # users following tag2 are spammer, newcomer, and following: false for unbanned_spammer
    given_tags = [awesome, spam]
    assert_equal [users(:admin)], test.followers_who_dont_follow_tags(given_tags)
    # now make unbanned_spammer following: false for both 'awesome' and 'spam' tags:
    tag_selections(:selection_four).update_attribute('following', false)
    given_tags = [awesome, spam]
    assert_equal [users(:unbanned_spammer), users(:admin)], test.followers_who_dont_follow_tags(given_tags)
  end

  test 'returns all users in this tag if none is following the given tags' do
    tag = tags(:spam)
    tag2 = tags(:test)
    tag1 = tags(:awesome)
    given_tags = [tag1, tag2]
    assert_equal [users(:spammer), users(:newcomer)], tag.followers_who_dont_follow_tags(given_tags).sort
  end

  test 'returns all users in this tag if none is following a given tag (a new one with no followers)' do
    tags = [tags(:spam)]
    newtag = Tag.new({name: 'newtag'})
    newtag.save
    given_tags = [newtag]
    assert_not_equal [], tags.collect(&:subscriptions).flatten.collect(&:user_id)
    assert_equal [users(:spammer), users(:newcomer)], tags.first.followers_who_dont_follow_tags(given_tags).sort
  end

  test 'Tag.trending(limit, start, end) returns most-used tags for a time period' do
    trending_tags = Tag.trending
    assert_not_nil trending_tags
    assert_not_equal [], trending_tags
    assert trending_tags.any?
    assert_not_nil Tag.trending(2, Time.now - 1.year, Time.now - 1.month)
  end

  test 'Tag.find_popular_notes returns most viewed notes with specified tag' do
    popular_notes = Tag.find_popular_notes('test')
    assert_not_nil popular_notes
  end

  test 'Tag.top_nodes returns most viewed nodes with specified tag and node type' do
    top_nodes = Tag.find_top_nodes_by_type(tagname:'awesome2', type:'page')
    assert_not_nil top_nodes
  end

  test 'contributors with specific tag name' do
    tag = tags(:test)
    contributors = Tag.contributors(tag.name)
    assert_equal [1, 2 , 5 , 6, 12, 19], contributors.pluck(:id)
  end

  test 'contributor_count with specific tag name' do
    tag = tags(:test)
    contributor_count = Tag.contributor_count(tag.name)
    assert_equal 6,contributor_count
  end

  test 'check sort according to followers ascending' do
    tags = Tag.joins(:node_tag, :node)
        .select('node.nid, node.status, term_data.*, community_tags.*')
        .where('node.status = ?', 1)
        .where('community_tags.date > ?', (DateTime.now - 1.month).to_i)
        .group(:name)
    tags = Tag.sort_according_to_followers(tags, "asc")
    followers = []
    tags.each do |i|
      followers << Tag.follower_count(i.name)
    end
    followers_sorted = followers.sort
    assert_equal followers_sorted, followers
  end

  test 'check sort according to followers descending' do
    tags = Tag.joins(:node_tag, :node)
        .select('node.nid, node.status, term_data.*, community_tags.*')
        .where('node.status = ?', 1)
        .where('community_tags.date > ?', (DateTime.now - 1.month).to_i)
        .group(:name)
    tags = Tag.sort_according_to_followers(tags, "desc")
    followers = []
    tags.each do |i|
      followers << Tag.follower_count(i.name)
    end
    followers_sorted = followers.sort.reverse
    assert_equal followers_sorted, followers
  end

  test 'graph data for cytoscape' do
    data = Tag.graph_data
    assert_not_nil data
    data = Tag.graph_data(10)
    assert_not_nil data
  end

  test 'contribution_graph_making' do
    tag = tags(:awesome)
    graph_making = tag.contribution_graph_making('note', @start, @fin).values
    notes = tag.nodes.where( type: 'note', created: @start.to_i..@fin.to_i).size

    assert_equal notes, graph_making.sum
  end


  test ' comment and quiz graph making' do
    tag = tags(:test)
    comment_graphs = tag.comment_graph(@start, @fin).values
    quiz_graphs = tag.quiz_graph(@start, @fin).values
    nids = tag.nodes.map{|node| node.nid}
    comments = Comment.where(nid: nids, timestamp: @start.to_i..@fin.to_i).count
    quiz = Node.questions.where(nid: nids, created: @start.to_i..@fin.to_i).count

    assert_equal comments, comment_graphs.sum
    assert_equal quiz.count, quiz_graphs.sum
  end

  test 'subscribtions graph' do
    tag = tags(:test)
    last_week_subscriptions = tag.subscriptions
      .where(created_at: (Time.now - 1.week)..Time.now)
      .count

    graph = tag.subscription_graph(Time.now - 1.week, Time.now)

    assert_equal last_week_subscriptions, graph.values.sum
    assert_equal Hash, graph.class
  end
end
