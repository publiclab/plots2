require 'test_helper'
class NodeTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @start = (Date.today - 1.year).to_time
    @fin = Date.today.to_time
  end

  test 'basic node attributes' do
    node = nodes(:one)
    assert_equal 'note', node.type
    assert_equal 1, node.status
    node = nodes(:about)
    assert_equal 'page', node.type
    assert_equal 1, node.status
    assert_equal [], node.location_tags
    assert node.body
    assert node.summary
  end

  test 'basic location attributes' do
    map = nodes(:map)
    map.add_tag('lat:123', users(:bob))
    map.add_tag('lon:34', users(:bob))
    assert map.has_power_tag('lat')
    assert map.has_power_tag('lon')
    assert_not_nil map.power_tag('lat')
    assert_not_nil map.power_tag('lon')
    assert map.lat
    assert map.lon
    assert_equal map.lat, map.power_tag('lat').split(':').first.to_f
    assert_equal map.lon, map.power_tag('lon').split(':').first.to_f
    assert map.location_tags
  end

  test 'adding a question:FOO style tag adds FOO tag as well; also for subtags' do
    node = nodes(:one)
    assert_difference 'node.tags.count', 2 do
      node.add_tag('question:kites', users(:bob))
    end
    assert node.has_tag('kites')
    assert_difference 'node.tags.count', 2 do
      node.add_tag('pm', users(:bob))
    end
    assert node.has_tag('particulate-matter')
  end

  test 'notify_callout_users' do
    saved, node, revision = Node.new_note(uid: users(:naman).id,
                    title: 'Note with mentioned users',
                    body: '@naman18996 and @jeffrey are being mentioned in the body')
    node.notify_callout_users
    emails = []
    ActionMailer::Base.deliveries.each do |m|
      if m.subject == "(##{node.id}) You were mentioned in a note"
        emails = emails + m.to
      end
    end
    assert_equal 2, emails.count
    assert_equal ["naman18996@yahoo.com", "jeff@publiclab.org"].to_set, emails.to_set
  end

  test 'emoji conversion' do
    node = nodes(:one)
    revision = node.latest
    revision.body = ':cat:'
    assert_equal "<p>🐱</p>\n", revision.render_body
    revision.body = '[notes:question:balloon-mapping]'
    assert_nil revision.render_body.match('❓')
  end

  test 'node mysql native fulltext search' do
    assert Node.count > 0
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      nodes = Node.search(query: 'organizers', limit: 1000)
      assert_not_nil nodes
      assert nodes.length > 0
      # now sorted by natural language match
      nodes_natural = Node.search(query: 'organizers', order: :natural, limit: 1000)
      assert_not_nil nodes_natural
      assert nodes_natural.length > 0
      assert_not_equal nodes_natural, nodes
      # now sorted by likes
      nodes_likes = Node.search(query: 'organizers', order: :likes, limit: 1000)
      assert_not_nil nodes_likes
      assert nodes_likes.length > 0
      assert_not_equal nodes_likes, nodes
      # now sorted by views
      nodes_views = Node.search(query: 'organizers', order: :views, limit: 1000)
      assert_not_nil nodes_views
      assert nodes_views.length > 0
      assert_not_equal nodes_views, nodes
    end
  end

  test 'node mysql native fulltext search returning tag-based matches' do
    assert Node.count > 0
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      nodes = Node.search(query: 'awesome', limit: 1000)
      assert_not_nil nodes
      assert nodes.length > 0
      assert_equal nodes.length, Tag.find_nodes_by_type('awesome', ['note', 'page']).length
    end
  end

  test 'create a feature' do
    node = Node.new(uid: users(:admin).id,
                    type: 'feature',
                    title: 'header-feature')
    assert node.save!
    assert_equal 'feature', node.type
    assert_equal "/feature/#{node.title.parameterize}", node.path
  end

  test 'create a map' do
    node = Node.new(uid: users(:bob).id,
                    type: 'map',
                    title: 'My map')
    assert node.save!
    assert_equal 'map', node.type
    username = users(:bob).username
    time = Time.now.strftime('%m-%d-%Y')
    title = node.title.parameterize
    assert_equal "/map/#{title}/#{time}", node.path
  end

  test 'create a research note' do
    node = Node.new(uid: users(:bob).id,
                    type: 'note',
                    title: 'My research note')
    assert node.save!
    assert_equal 'note', node.type
    username = users(:bob).username
    time = Time.now.strftime('%m-%d-%Y')
    title = node.title.parameterize
    assert_equal "/notes/#{username}/#{time}/#{title}", node.path
    assert_equal "/questions/#{username}/#{time}/#{title}",
                 node.path(:question)
  end

  test 'edit a research note and check path' do
    original_title = 'My research note'
    node = Node.new(uid: users(:bob).id,
                    type: 'note',
                    title: original_title)
    assert node.save!
    node.title = 'I changed my mind'
    username = users(:bob).username
    time = Time.now.strftime('%m-%d-%Y')
    title = node.title.parameterize
    new_title = original_title.parameterize
    assert_not_equal "/notes/#{username}/#{time}/#{title}", node.path
    assert_equal "/notes/#{username}/#{time}/#{new_title}", node.path
  end

  # new_note also generates a revision
  test 'create a research note with new_note' do
    assert !users(:jeff).first_time_poster
    saved, node, revision = Node.new_note(uid: users(:jeff).uid,
                                          title: 'Title',
                                          body: 'New note body')
    assert saved
    assert_equal 1, node.status
    assert_equal 1, revision.status
    assert_not_nil node.latest
    assert_equal 'note', node.type
  end

  test 'first-time poster creates a research note with new_note' do
    assert users(:lurker).first_time_poster
    saved, node, revision = Node.new_note(uid: users(:lurker).uid,
                                          title: 'Title',
                                          body: 'New note body')
    assert saved
    assert_equal 4, node.status
    assert_equal 1, revision.status
  end

  test 'spam a note' do
    node = nodes(:one).spam
    assert_equal 0, node.status
  end

  test 'publish a note' do
    node = nodes(:spam).publish
    assert_equal 1, node.status
  end

  test 'create a wiki page' do
    node = Node.new(uid: users(:bob).id,
                    type: 'page',
                    title: 'My wiki page')
    assert node.save!
    assert_equal 'page', node.type
    assert_equal "/wiki/#{node.title.parameterize}", node.path
  end

  test 'create a wiki page with new as title' do
    array = ['new', 'create', 'update', 'edit', 'delete']
    array.each { |x|
    node = Node.new(uid: users(:bob).id,
                    type: 'page',
                    title: x)
    assert_not node.valid?
    assert_equal 'page', node.type
  }
  end

  test 'create a wiki page with Node.new_wiki' do
    node = Node.new_wiki(uid: users(:bob).id,
                         type: 'page',
                         title: 'My wiki page',
                         body: 'Wiki page content/body')[1] # returns an array, oddly. refactor this API!
    assert node.save!
    assert_equal users(:bob).id, node.uid
    assert_equal 'page', node.type
    assert_equal 'My wiki page', node.title
    assert_equal 'Wiki page content/body', node.body
  end

  test 'wikipage with wrong title should not be created' do
    node = Node.new(uid: users(:bob).id,
                    type: 'page')
    words = %w(create update delete new edit)
    words.each do |word|
      node.title = word.capitalize
      assert_not node.save
    end
  end

  test 'research note with empty/blank title should not be created' do
    node = Node.new(uid: users(:bob).id,
                    type: 'note')
    titles = [ '', ' ' * 5 ]
    titles.each do |t|
      node.title = t
      assert_not node.valid?
    end
  end

  test 'research note with duplicate title should not be created' do
    node = Node.new(uid: users(:bob).id,
                    type: 'note',
                    title: 'My research note')
    dup_node = node.dup
    node.save
    assert_not dup_node.save
  end

  test 'title should not be too short' do
    node = Node.new(uid: users(:bob).id,
                    type: 'note',
                    title: 'ok')
    assert_not node.valid?
  end
  test 'create a node_revision' do
    # in testing, uid and id should be matched, although this is not yet true in production db
    revision_count = nodes(:one).revisions.length
    node_revision =  Revision.new(uid: users(:bob).id,
                                  nid: nodes(:one).nid)
    node_revision.title = 'My new node'
    node_revision.body = 'My new node'
    assert node_revision.save!
    assert_equal revision_count + 1, nodes(:one).revisions.count
  end

  test 'latest revision based on timestamp' do
    node = nodes(:spam_targeted_page)

    assert node.revisions.size > 1
    assert_equal node.revisions.first, node.latest
    assert node.revisions.first.timestamp.to_i > node.revisions.last.timestamp.to_i
    assert_not_equal node.revisions.last, node.latest
    assert_equal node.revision.order('timestamp DESC').first, node.latest
  end

  test 'latest revision not a moderated revision' do
    node = nodes(:spam_targeted_page)

    assert node.revisions.size > 1
    assert_equal node.revisions.first, node.latest

    node.latest.spam

    assert_not_equal node.revisions.first, node.latest
    assert_equal 1, node.latest.status
  end

  test 'should have tags, node_tags, and tagnames' do
    node = nodes(:one)
    assert !node.tags.empty?
    assert_equal node.tags, node.tag
    assert !node.node_tags.empty?
    assert_not_nil node.tagnames
    assert node.tagnames.first.is_a?(String)
    assert_equal 'test awesome spectrometer activity:spectrometer', node.tagnames.join(' ')
    # used to generate CSS classes:
    assert_equal 'tag-test tag-awesome tag-spectrometer tag-activity-spectrometer', node.tagnames_as_classes
  end

  test 'should have subscribers' do
    node = tag_selections(:awesome).tag.nodes.first
    assert_equal 7, node.subscribers.length
  end

  test 'should have place node icon according to tagging' do
    node = nodes(:place)
    assert_equal node.icon, 'flag'
  end

  # test "should not save node without title, or anything else" do
  # node = Node.new
  # assert !node.save
  # end

  test 'reports weekly_tallies' do
    node = nodes(:one)
    assert_not_nil Node.weekly_tallies
    assert_not_nil Node.weekly_tallies('page', 2, Time.now - 1.month)
  end

  test 'should show normal tags' do
    node = nodes(:question)
    assert_equal node.normal_tags, [node_tags(:test2)]
  end

  test 'returns power tag' do
    node = nodes(:blog)
    assert_equal node.power_tag_objects("lat") , [node_tags(:map_lat)]
  end

  test 'has power tag' do
    node = nodes(:blog)
    assert node.has_power_tag("lat")
  end

  test 'should show question icon for question node' do
    node = nodes(:question)
    assert_equal 'question-circle', node.icon
  end

  test 'should find all research notes' do
    notes = Node.research_notes
    expected = [nodes(:one), nodes(:spam), nodes(:first_timer_note), nodes(:blog),
                nodes(:moderated_user_note), nodes(:activity), nodes(:upgrade),
                nodes(:draft), nodes(:post_test1), nodes(:post_test2),
                nodes(:post_test3), nodes(:post_test4), nodes(:scraped_image), nodes(:search_trawling),
                nodes(:purple_air_without_hyphen), nodes(:purple_air_with_hyphen),
                nodes(:sun_note), nodes(:sunny_day_note)]
    assert_equal expected, notes
  end

  test 'should find all questions associated with this node' do
    assert_not_nil nodes(:one).questions
  end

  test 'should find all questions' do
    questions = Node.questions
    expected = [nodes(:question), nodes(:question2), nodes(:first_timer_question), nodes(:question3), nodes(:sun_question)]
    assert_equal expected, questions
  end

  test 'should find all activities associated with this node' do
    assert_not_nil nodes(:one).activities
  end

  test 'should find all activity notes' do
    activities = Node.activities('coding')
    expected = [nodes(:moderated_user_note), nodes(:activity)]
    assert_equal expected, activities
  end

  test 'should find all upgrades associated with this node' do
    assert_not_nil nodes(:one).upgrades
  end

  test 'should find all upgrade notes' do
    activities = Node.upgrades('latest')
    expected = [nodes(:moderated_user_note), nodes(:upgrade)]
    assert_equal expected, activities
  end

  test 'replacing content in a node with node.replace()' do
    node = nodes(:about)
    replaced = node.replace('Public', 'Private', users(:bob))

    assert replaced
    assert_equal 'All about Private Lab', node.body
  end

  test "not replacing content in a node with node.replace() if there is no matching 'before' text" do
    node = nodes(:about)
    assert !node.body.include?('Elephant')

    replaced = node.replace('Elephant', 'Tiger', users(:bob))

    assert !replaced
    assert_equal 'All about Public Lab', node.body
  end

  test "not replacing content in a node with node.replace() if there is more than one matching 'before' text" do
    node = nodes(:about)
    revision = node.latest
    revision.body = 'Jingle Jingle Bells'
    assert revision.save

    replaced = node.replace('Jingle', 'Bells', users(:bob))

    assert !replaced
    assert_equal 'Jingle Jingle Bells', node.body
  end

  test "user likes node or not" do
    node = nodes(:one)
    user = users(:jeff)
    assert !node.is_liked_by(user)

  end

  test "should change the number of cache likes" do
    node = nodes(:one)
    user = users(:jeff)
    current_cached_likes = node.cached_likes

    node.toggle_like(user)

    cached_like = node.cached_likes
    assert_equal cached_like-1 , current_cached_likes
  end

  test "should create a like" do
    current_user = User.find 2
    note = Node.where(type: 'note', status: 1).first
    cached_likes = note.cached_likes

    Node.like(note.nid , current_user)

    note = Node.find note.id
    assert_equal note.likers.length, note.cached_likes
    assert_equal cached_likes + 1, note.cached_likes
  end

  test "should delete a like" do
    current_user = User.find 2
    note = Node.where(type: 'note', status: 1).first

    Node.like(note.nid , current_user)
    note = Node.find note.id
    cached_likes = note.cached_likes

    Node.unlike(note.nid , current_user)
    note = Node.find note.id
    assert_equal note.likers.length, note.cached_likes
    assert_equal cached_likes-1 , note.cached_likes
  end

  test "return nodes tagged by author and user_id" do
    jeff = users(:jeff)
    jeff_notes = nodes(:one)
    jeff_notes.add_tag('replication:123',jeff)
    tagged_note = Tag.tagged_nodes_by_author('replication:123',2).first
    assert_not_nil tagged_note
    assert_equal jeff_notes, tagged_note
  end

  test "return nodes tagged by tagname and user_id with *" do
    jeff = users(:jeff)
    jeff_notes = nodes(:one)
    jeff_notes.add_tag('balloon-mapping',jeff)
    tagged_note = Tag.tagged_nodes_by_author('balloon*',2).first
    assert_not_nil tagged_note
    assert_equal jeff_notes, tagged_note
  end

  test 'should delete associated comments when a node is deleted' do
    node = nodes(:one)
    assert_equal 7, node.comments.count
    deleted_node = node.destroy
    assert_equal 0, node.comments.count
  end

  test 'should delete associated node selections when a node is deleted' do
    node = nodes(:one)
    node_selection = node_selections(:unbanned_spammer_like)
    node.destroy
    assert_equal node.node_selections.count, 0
  end

  test 'should show scraped image' do
    node = nodes(:scraped_image)
    assert_equal '/images/pl.png', node.scraped_image
  end

  test 'contribution graph making' do
    graph_notes = Node.contribution_graph_making('note', @start, @fin)
    graph_wiki = Node.contribution_graph_making('page', @start, @fin)
    notes = Node.where(type: 'note', created: @start.to_i..@fin.to_i).count
    wiki = Node.where(type: 'page', created: @start.to_i..@fin.to_i).count

    assert graph_notes.class, Hash
    # TODO: figure out issue here and re-enable! No rush :-)
    # assert_equal notes, graph_notes.values.sum
    # assert_equal wiki, graph_wiki.values.sum
  end

  # node.authors should be anyone who's written a revision for this node (a wiki, presumably)
  test 'authors' do
    authors = Node.last.authors

    assert authors
    assert_equal 1, authors.length
  end

  test 'find by tagname and user id' do
    # Should test for each type of node: wiki, notes, questions
    assert_equal 'Chicago', Node.find_by_tag_and_author('chapter', 1, 'wiki').first.title
    assert_equal 'Canon A1200 IR conversion at PLOTS Barnraising at LUMCON', Node.find_by_tag_and_author('awesome', 2, 'notes').first.title
    assert_equal 'Question by a moderated user', Node.find_by_tag_and_author('question:spectrometer', 9, 'questions').first.title
  end
  test 'non-approved users should not be able to add tags' do
    node = nodes(:one)
    assert_difference 'node.tags.count', 0 do
      node.add_tag('myspamtag', users(:spammer))
    end
    assert_not node.has_tag('myspamtag')
  end

  test 'for_tagname_and_type with notes' do
    tag = tags(:sunny_day)
    node = nodes(:sunny_day_note)

    nodes = Node.for_tagname_and_type(tag.name)
    assert nodes.include?(node), "Should include note tagged with sunny-day"
  end

  test 'for_tagname_and_type with a parent tag' do
    tag = tags(:sun)
    node1 = nodes(:sun_note)
    node2 = nodes(:sunny_day_note)

    nodes = Node.for_tagname_and_type(tag.name)
    assert nodes.include?(node1), "Should include note with parent tag (sun)"
    assert nodes.include?(node2), "Should include note with child tag (sunny-day)"
  end

  test 'for_tagname_and_type with questions' do
    tag = tags(:sun)
    node = nodes(:sun_question)

    Node.expects(:for_question_tagname_and_type).once
    Node.for_tagname_and_type(tag.name, 'note', question: true)
  end

  test 'for_question_tagname_and_type' do
    tag = tags(:sun)
    node = nodes(:sun_question)

    nodes = Node.for_question_tagname_and_type(tag.name, 'note')
    assert nodes.include?(node), "Should include question tagged with sun:question"
  end

  test 'for_tagname_and_type with wiki' do
    tag = tags(:sunny_day)
    node = nodes(:sunny_day_wiki)

    nodes = Node.for_tagname_and_type(tag.name, 'page')
    assert nodes.include?(node), "Should include wiki tagged with sunny-day"
  end

  test 'for_tagname_and_type with wildcard' do
    tag = tags(:sun)

    Node.expects(:for_wildcard_tagname_and_type).once
    Node.for_tagname_and_type(tag.name + "*", 'note', wildcard: true)
  end

  test 'for_wildcard_tagname_and_type' do
    tag = tags(:sun)
    node1 = nodes(:sun_note)
    node2 = nodes(:sunny_day_note)

    nodes = Node.for_wildcard_tagname_and_type(tag.name + "*", 'note')
    assert nodes.include?(node1), "Should include note tagged with sun for sun*"
    assert nodes.include?(node2), "Should include note tagged with sunny-day for sun*"
  end
end
