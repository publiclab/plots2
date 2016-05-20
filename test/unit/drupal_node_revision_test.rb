require 'test_helper'

class DrupalNodeRevisionsTest < ActiveSupport::TestCase

  test "create a node_revision" do
    node =  DrupalNode.new({:uid => rusers(:bob).id})
    node.title = "My new node"
    assert node.save!
    # in testing, uid and id should be matched, although this is not yet true in production db
    node_revision =  DrupalNodeRevision.new({
      title: "My new node",
      body: "My new node",
      uid: rusers(:bob).id,
      nid: node(:one).nid
    })
    assert node_revision.save!
    assert_not_equal 0, node_revision.timestamp
    assert_not_nil node_revision.timestamp
  end

  test "spam and republish a revision" do
    revision = node_revisions(:unmoderated_spam_revision)
    assert_equal 1, revision.status
    revision.spam
    assert_equal 0, revision.status
    revision.publish
    assert_equal 1, revision.status
  end

  test "previous and next revisions" do

    revision = node_revisions(:about)
# does previous respect status = 1? no.
    new_revision = DrupalNodeRevision.new({
      title: revision.title,
      body:  'New body',
      uid:   rusers(:bob).id,
      nid:   revision.nid
    })

    assert_difference 'revision.parent.revisions.length', 1 do
      assert new_revision.save
      assert_not_equal revision.timestamp, new_revision.timestamp
    end

    assert_equal new_revision.previous, revision
    assert_equal revision.next, new_revision

    new_revision_2 = DrupalNodeRevision.new({
      title: revision.title,
      body:  'New body 2',
      uid:   rusers(:bob).id,
      nid:   revision.nid
    })

    assert_difference 'revision.parent.revisions.length', 1 do
      assert new_revision_2.save
    end

    # future-date the timestamp since it's second resolution and tests run faster than that:
    new_revision_2.timestamp = Time.now.to_i + 1
    new_revision_2.save

    assert_not_equal new_revision_2.timestamp, new_revision.timestamp
    assert_equal new_revision_2.previous, new_revision
    assert_equal new_revision.next, new_revision_2

  end

  test "should recognize hashtags and link them" do
    revision = node_revisions(:hashtag_one)
    assert_includes revision.render_body, '<a href="/tag/hashtag">#hashtag</a>'
  end

  test "should ignore Headers as hashtags in markdown" do
    revision = node_revisions(:hashtag_two)
    assert_not_includes revision.render_body, '<a href="/tag/Heading 1">#Heading 1</a>'
  end

  test "should render correct link for images in email" do
    revision = node_revisions(:email)
    assert_includes revision.render_body_email, 'https://i.publiclab.org/system/images/photos/000/016/229/original/admin_tooltip.png'
  end
end
