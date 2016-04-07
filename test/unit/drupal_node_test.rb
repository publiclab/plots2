require 'test_helper'

class DrupalNodeTest < ActiveSupport::TestCase

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

  #test "should not save node without title, or anything else" do
    #node = DrupalNode.new
    #assert !node.save
  #end

end
