require 'test_helper'

class NodeTest < ActiveSupport::TestCase
  test 'basic node attributes' do
    node = node(:one)
    assert_equal 'note', node.type
    assert_equal 1, node.status
    node = node(:about)
    assert_equal 'page', node.type
    assert_equal 1, node.status
  end

  test 'create a node' do
    # in testing, uid and id should be matched, although this is not yet true in production db
    node = Node.new(uid: rusers(:bob).id,
                    type: 'note',
                    title: 'My new node for node creation testing')
    assert node.save
  end

  test 'create a feature' do
    node = Node.new(uid: rusers(:admin).id,
                    type: 'feature',
                    title: 'header-feature')
    assert node.save!
    username = rusers(:bob).username
    assert_equal "/feature/#{node.title.parameterize}", node.path
    assert_equal 'feature', node.type
  end

  test 'create a research note' do
    node = Node.new(uid: rusers(:bob).id,
                    type: 'note',
                    title: 'My research note')
    assert node.save!
    username = rusers(:bob).username
    assert_equal "/notes/#{username}/#{Time.now.strftime('%m-%d-%Y')}/#{node.title.parameterize}", node.path
    assert_equal "/questions/#{username}/#{Time.now.strftime('%m-%d-%Y')}/#{node.title.parameterize}", node.path(:question)
    assert_equal 'note', node.type
  end

  test 'edit a research note and check path' do
    original_title = 'My research note'
    node = Node.new(uid: rusers(:bob).id,
                    type: 'note',
                    title: original_title)
    assert node.save!
    node.title = 'I changed my mind'
    username = rusers(:bob).username
    assert_not_equal "/notes/#{username}/#{Time.now.strftime('%m-%d-%Y')}/#{node.title.parameterize}", node.path
    assert_equal "/notes/#{username}/#{Time.now.strftime('%m-%d-%Y')}/#{original_title.parameterize}", node.path
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
    node = node(:one).spam
    assert_equal 0, node.status
  end

  test 'publish a note' do
    node = node(:spam).publish
    assert_equal 1, node.status
  end

  test 'create a wiki page' do
    node = Node.new(uid: rusers(:bob).id,
                    type: 'page',
                    title: 'My wiki page')
    assert node.save!
    assert_equal 'page', node.type
  end

  test 'create a wiki page with Node.new_wiki' do
    node = Node.new_wiki(uid: rusers(:bob).id,
                         type: 'page',
                         title: 'My wiki page',
                         body: 'Wiki page content/body')[1] # returns an array, oddly. refactor this API!
    assert node.save!
    assert_equal rusers(:bob).id, node.uid
    assert_equal 'page', node.type
    assert_equal 'My wiki page', node.title
    assert_equal 'Wiki page content/body', node.body
  end

  test 'create a node_revision' do
    # in testing, uid and id should be matched, although this is not yet true in production db
    revision_count = node(:one).revisions.length
    node_revision =  Revision.new(uid: rusers(:bob).id,
                                  nid: node(:one).nid)
    node_revision.title = 'My new node'
    node_revision.body = 'My new node'
    assert node_revision.save!
    assert_equal revision_count + 1, node(:one).revisions.count
  end

  test 'latest revision based on timestamp' do
    node = node(:spam_targeted_page)
    assert node.revisions.count > 1
    assert_equal node.revisions.first, node.latest
    assert node.revisions.first.timestamp.to_i > node.revisions.last.timestamp.to_i
    assert_not_equal node.revisions.last, node.latest
    assert_equal node.revision.order('timestamp DESC').first, node.latest
  end

  test 'latest revision not a moderated revision' do
    node = node(:spam_targeted_page)
    assert node.revisions.count > 1
    assert_equal node.revisions.first, node.latest
    node.latest.spam
    assert_not_equal node.revisions.first, node.latest
    assert_equal 1, node.latest.status
  end

  test 'should have tags, community_tags, and tagnames' do
    node = node(:one)
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
    node = tag_selection(:awesome).tag.nodes.first
    assert_equal 7, node.subscribers.length
  end

  test 'should have place node icon according to tagging' do
    node = node(:place)
    assert_equal node.icon, 'flag'
  end

  # test "should not save node without title, or anything else" do
  # node = Node.new
  # assert !node.save
  # end

  test 'reports weekly_tallies' do
    node = node(:one)
    assert_not_nil Node.weekly_tallies
    assert_not_nil Node.weekly_tallies('page', 2, Time.now - 1.month)
  end

  test 'should show normal tags' do
    node = node(:question)
    assert_equal node.normal_tags, [community_tags(:test2)]
  end

  test 'should show question icon for question node' do
    node = node(:question)
    assert_equal 'question-circle', node.icon
  end

  test 'should find all research notes' do
    notes = Node.research_notes
    expected = [node(:one), node(:spam), node(:first_timer_note), node(:blog), node(:moderated_user_note), node(:activity), node(:upgrade)]
    assert_equal expected, notes
  end

  test 'should find all questions' do
    questions = Node.questions
    expected = [node(:question), node(:question2), node(:first_timer_question), node(:question3)]
    assert_equal expected, questions
  end

  test 'should find all activity notes' do
    activities = Node.activities('coding')
    expected = [node(:moderated_user_note), node(:activity)]
    assert_equal expected, activities
  end

  test 'should find all upgrade notes' do
    activities = Node.upgrades('latest')
    expected = [node(:moderated_user_note), node(:upgrade)]
    assert_equal expected, activities
  end

  test 'replacing content in a node with node.replace()' do
    node = node(:about)
    replaced = node.replace('Public', 'Private', rusers(:bob))

    assert replaced
    assert_equal 'All about Private Lab', node.body
  end

  test "not replacing content in a node with node.replace() if there is no matching 'before' text" do
    node = node(:about)
    assert !node.body.include?('Elephant')

    replaced = node.replace('Elephant', 'Tiger', rusers(:bob))

    assert !replaced
    assert_equal 'All about Public Lab', node.body
  end

  test "not replacing content in a node with node.replace() if there is more than one matching 'before' text" do
    node = node(:about)
    revision = node.latest
    revision.body = 'Jingle Jingle Bells'
    assert revision.save

    replaced = node.replace('Jingle', 'Bells', rusers(:bob))

    assert !replaced
    assert_equal 'Jingle Jingle Bells', node.body
  end
end
