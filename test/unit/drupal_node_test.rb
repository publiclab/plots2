require 'test_helper'

class DrupalNodeTest < ActiveSupport::TestCase

  test "basic node attributes" do
    node = node(:one)
    assert_equal 'note', node.type
    assert_equal 1, node.status
    node = node(:about)
    assert_equal 'page', node.type
    assert_equal 1, node.status
  end

  test "create a node" do
    # in testing, uid and id should be matched, although this is not yet true in production db
    node =  DrupalNode.new({:uid => rusers(:bob).id})
    node.title = "My new node"
    assert node.save!
  end

  test "create a research note" do
    node =  DrupalNode.new({
      uid: rusers(:bob).id,
      type: 'note',
      title: 'My research note'
    })
    assert node.save!
    assert_equal 'note', node.type
  end

  # new_note also generates a revision
  test "create a research note with new_note" do
    assert !users(:jeff).first_time_poster
    saved, node, revision = DrupalNode.new_note({
      uid: users(:jeff).uid,
      title: "Title",
      body: "New note body"
    })
    assert saved
    assert_equal 1, node.status
    assert_equal 1, revision.status
    assert_not_nil node.latest
    assert_equal 'note', node.type
  end

  test "first-time poster creates a research note with new_note" do
    assert users(:lurker).first_time_poster
    saved, node, revision = DrupalNode.new_note({
      uid: users(:lurker).uid,
      title: "Title",
      body: "New note body"
    })
    assert saved
    assert_equal 4, node.status
    assert_equal 1, revision.status
  end

  test "spam a note" do
    node = node(:one).spam
    assert_equal 0, node.status
  end

  test "publish a note" do
    node = node(:spam).publish
    assert_equal 1, node.status
  end

  test "create a wiki page" do
    node =  DrupalNode.new({
      uid: rusers(:bob).id,
      type: 'page',
      title: 'My wiki page'
    })
    assert node.save!
    assert_equal 'page', node.type
  end

  test "create a wiki page with DrupalNode.new_wiki" do
    node = DrupalNode.new_wiki({
      uid: rusers(:bob).id,
      type: 'page',
      title: 'My wiki page',
      body: 'Wiki page content/body'
    })[1] # returns an array, oddly. refactor this API!
    assert node.save!
    assert_equal rusers(:bob).id, node.uid
    assert_equal 'page', node.type
    assert_equal 'My wiki page', node.title
    assert_equal 'Wiki page content/body', node.body
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
    node = node(:spam_targeted_page)
    assert node.revisions.count > 1
    assert_equal node.revisions.first, node.latest
    assert node.revisions.first.timestamp.to_i > node.revisions.last.timestamp.to_i
    assert_not_equal node.revisions.last, node.latest
    assert_equal node.drupal_node_revision.order('timestamp DESC').first, node.latest
  end

  test "latest revision not a moderated revision" do
    node = node(:spam_targeted_page)
    assert node.revisions.count > 1
    assert_equal node.revisions.first, node.latest
    node.latest.spam
    assert_not_equal node.revisions.first, node.latest
    assert_equal 1, node.latest.status
  end

  test "should have tags" do
    node = node(:one)
    assert node.tags.length > 0
    assert_equal node.tags, node.drupal_tag
    assert node.community_tags.length > 0
    assert_equal node.community_tags, node.drupal_node_community_tag
  end

  test "should have subscribers" do
    node = tag_selection(:awesome).tag.nodes.first
    assert_equal 4, node.subscribers.length
  end

  test "should have place node icon according to tagging" do
    node = node(:place)
    assert_equal node.icon, 'flag'
  end

  #test "should not save node without title, or anything else" do
    #node = DrupalNode.new
    #assert !node.save
  #end

  test "reports weekly_tallies" do
    node = node(:one)
    assert_not_nil DrupalNode.weekly_tallies
    assert_not_nil DrupalNode.weekly_tallies('page', 2, Time.now - 1.month)
  end

end
