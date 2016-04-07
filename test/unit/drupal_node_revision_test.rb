require 'test_helper'

class DrupalNodeRevisionsTest < ActiveSupport::TestCase

  test "create a node_revision" do
    node =  DrupalNode.new({:uid => rusers(:bob).id})
    node.title = "My new node"
    assert node.save!
    # in testing, uid and id should be matched, although this is not yet true in production db
    node_revision =  DrupalNodeRevision.new({
      :uid => rusers(:bob).id,
      :nid => node(:one).nid
    })
    node_revision.title = "My new node"
    node_revision.body = "My new node"
    assert node_revision.save!
  end

  test "spam and republish a revision" do
    revision = node_revisions(:unmoderated_spam_revision)
    assert_equal 1, revision.status
    revision.spam
    assert_equal 0, revision.status
    revision.publish
    assert_equal 1, revision.status
  end

end
