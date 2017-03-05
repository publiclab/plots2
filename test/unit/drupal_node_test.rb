require 'test_helper'

class DrupalNodeTest < ActiveSupport::TestCase

  test "basic node attributes" do
    node1 = node(:one)
    assert_equal 'note', node1.type
    assert_equal 1, node1.status
    node1 = node(:about)
    assert_equal 'page', node1.type
    assert_equal 1, node1.status
  end

  test "create a node" do
    # in testing, uid and id should be matched, although this is not yet true in production db
    node1 =  Node.new({
      uid: rusers(:bob).id,
      type: 'note',
      title: 'My new node for node creation testing'
    })
    assert node1.save
  end

  test "create a feature" do
    node1 =  Node.new({
      uid: rusers(:admin).id,
      type: 'feature',
      title: 'header-feature'
    })
    assert node1.save!
    username = rusers(:bob).username
    assert_equal "/feature/#{node1.title.parameterize}", node1.path
    assert_equal 'feature', node1.type
  end

  test "create a research note" do
    node1 =  Node.new({
      uid: rusers(:bob).id,
      type: 'note',
      title: 'My research note'
    })
    assert node1.save!
    username = rusers(:bob).username
    assert_equal "/notes/#{username}/#{Time.now.strftime("%m-%d-%Y")}/#{node1.title.parameterize}", node1.path
    assert_equal "/questions/#{username}/#{Time.now.strftime("%m-%d-%Y")}/#{node1.title.parameterize}", node1.path(:question)
    assert_equal 'note', node1.type
  end

  test "edit a research note and check path" do
    original_title = 'My research note'
    node1 =  Node.new({
      uid: rusers(:bob).id,
      type: 'note',
      title: original_title
    })
    assert node1.save!
    node1.title = "I changed my mind"
    username = rusers(:bob).username
    assert_not_equal "/notes/#{username}/#{Time.now.strftime("%m-%d-%Y")}/#{node1.title.parameterize}", node1.path
    assert_equal "/notes/#{username}/#{Time.now.strftime("%m-%d-%Y")}/#{original_title.parameterize}", node1.path
  end

  # new_note also generates a revision
  test "create a research note with new_note" do
    assert !users(:jeff).first_time_poster
    saved, node1, revision = Node.new_note({
      uid: users(:jeff).uid,
      title: "Title",
      body: "New note body"
    })
    assert saved
    assert_equal 1, node1.status
    assert_equal 1, revision.status
    assert_not_nil node1.latest
    assert_equal 'note', node1.type
  end

  test "first-time poster creates a research note with new_note" do
    assert users(:lurker).first_time_poster
    saved, node1, revision = Node.new_note({
      uid: users(:lurker).uid,
      title: "Title",
      body: "New note body"
    })
    assert saved
    assert_equal 4, node1.status
    assert_equal 1, revision.status
  end

  test "spam a note" do
    node1 = node(:one).spam
    assert_equal 0, node1.status
  end

  test "publish a note" do
    node1 = node(:spam).publish
    assert_equal 1, node1.status
  end

  test "create a wiki page" do
    node1 =  Node.new({
      uid: rusers(:bob).id,
      type: 'page',
      title: 'My wiki page'
    })
    assert node1.save!
    assert_equal 'page', node1.type
  end

  test "create a wiki page with Node.new_wiki" do
    node1 = Node.new_wiki({
      uid: rusers(:bob).id,
      type: 'page',
      title: 'My wiki page',
      body: 'Wiki page content/body'
    })[1] # returns an array, oddly. refactor this API!
    assert node1.save!
    assert_equal rusers(:bob).id, node1.uid
    assert_equal 'page', node1.type
    assert_equal 'My wiki page', node1.title
    assert_equal 'Wiki page content/body', node1.body
  end

  test "create a node_revision" do
    # in testing, uid and id should be matched, although this is not yet true in production db
    revision_count = node(:one).revisions.length
    node_revision =  DrupalNodeRevision.new({
      :uid => rusers(:bob).id,
      :nid => node(:one).nid
    })
    node_revision.title = "My new node"
    node_revision.body = "My new node"
    assert node_revision.save!
    assert_equal revision_count + 1, node(:one).revisions.count
  end

  test "latest revision based on timestamp" do
    node1 = node(:spam_targeted_page)
    assert node1.revisions.count > 1
    assert_equal node1.revisions.first, node1.latest
    assert node1.revisions.first.timestamp.to_i > node1.revisions.last.timestamp.to_i
    assert_not_equal node1.revisions.last, node1.latest
    assert_equal node1.drupal_node_revision.order('timestamp DESC').first, node1.latest
  end

  test "latest revision not a moderated revision" do
    node1 = node(:spam_targeted_page)
    assert node1.revisions.count > 1
    assert_equal node1.revisions.first, node1.latest
    node1.latest.spam
    assert_not_equal node1.revisions.first, node1.latest
    assert_equal 1, node1.latest.status
  end

  test "should have tags" do
    node1 = node(:one)
    assert node1.tags.length > 0
    assert_equal node1.tags, node1.tag
    assert node1.community_tags.length > 0
    assert_equal node1.community_tags, node1.drupal_node_community_tag
  end

  test "should have subscribers" do
    node1 = tag_selection(:awesome).tag.nodes.first
    assert_equal 4, node1.subscribers.length
  end

  test "should have place node icon according to tagging" do
    node1 = node(:place)
    assert_equal node1.icon, 'flag'
  end

  #test "should not save node without title, or anything else" do
    #node = DrupalNode.new
    #assert !node.save
  #end

  test "reports weekly_tallies" do
    node1 = node(:one)
    assert_not_nil Node.weekly_tallies
    assert_not_nil Node.weekly_tallies('page', 2, Time.now - 1.month)
  end

  test "should show normal tags" do
    node1 = node(:question)
    assert_equal node1.normal_tags, [community_tags(:test2)]
  end

  test "should show question icon for question node" do
    node1 = node(:question)
    assert_equal 'question-circle', node1.icon
  end

  test "should find all research notes" do
    notes = Node.research_notes
    expected = [node(:one), node(:spam), node(:first_timer_note), node(:blog), node(:moderated_user_note), node(:activity), node(:upgrade)]
    assert_equal expected, notes
  end

  test "should find all questions" do
    questions = DrupalNode.questions
    expected = [node(:question), node(:question2), node(:first_timer_question), node(:question3)]
    assert_equal expected, questions
  end

  test "should find all activity notes" do
    activities = Node.activities("coding")
    expected = [node(:moderated_user_note), node(:activity)]
    assert_equal expected, activities
  end

  test "should find all upgrade notes" do
    activities = Node.upgrades("latest")
    expected = [node(:moderated_user_note), node(:upgrade)]
    assert_equal expected, activities
  end

  test "replacing content in a node with node.replace()" do
    node1 = node(:about)
    replaced = node.replace("Public", "Private", rusers(:bob))

    assert replaced
    assert_equal "All about Private Lab", node1.body
  end

end
