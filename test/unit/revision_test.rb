require 'test_helper'

class RevisionsTest < ActiveSupport::TestCase
  test 'create a node_revision' do
    node = Node.new(uid: rusers(:bob).id,
                    type: 'page')
    node.title = 'My new node for revision testing'
    assert node.save!
    # in testing, uid and id should be matched, although this is not yet true in production db
    node_revision = Revision.new(title: 'My new node',
                                 body: 'My new node',
                                 uid: rusers(:bob).id,
                                 nid: node(:one).nid)
    assert node_revision.save!
    assert_not_equal 0, node_revision.timestamp
    assert_not_nil node_revision.timestamp
  end

  test "create a feature's node_revision" do
    node = Node.new(uid: rusers(:admin).id,
                    type: 'feature',
                    title: 'footer-feature')
    assert node.save!
    revision = node.new_revision(nid:   node.id,
                                 uid:   rusers(:admin).uid,
                                 title: 'footer-feature',
                                 body: 'Testing')
    assert revision.save!
    assert_equal 'Testing', revision.body
    assert_equal revision.body, node.latest.body
  end

  test 'spam and republish a revision' do
    revision = node_revisions(:unmoderated_spam_revision)
    assert_equal 1, revision.status
    revision.spam
    assert_equal 0, revision.status
    revision.publish
    assert_equal 1, revision.status
  end

  test 'previous and next revisions' do
    revision = node_revisions(:about)
    # does previous respect status = 1? no.
    new_revision = Revision.new(title: revision.title,
                                body:  'New body',
                                uid:   rusers(:bob).id,
                                nid:   revision.nid)

    assert_difference 'revision.parent.revisions.length', 1 do
      assert new_revision.save
      assert_not_equal revision.timestamp, new_revision.timestamp
    end

    assert_equal new_revision.previous, revision
    assert_equal revision.next, new_revision

    new_revision_2 = Revision.new(title: revision.title,
                                  body:  'New body 2',
                                  uid:   rusers(:bob).id,
                                  nid:   revision.nid)

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

  test 'should recognize hashtags and link them' do
    revision = node_revisions(:hashtag_one)
    assert_includes revision.render_body, '<a href="/tag/hashtag">#hashtag</a>'
  end

  test 'should ignore Headers as hashtags in markdown' do
    revision = node_revisions(:hashtag_two)
    assert_not_includes revision.render_body, '<a href="/tag/Heading 1">#Heading 1</a>'
  end

  test 'should render correct link for images in email' do
    revision = node_revisions(:email)
    assert_includes revision.render_body_email(request_host), '//i.publiclab.org/system/images/photos/000/016/229/original/admin_tooltip.png'
  end

  test 'should add tags for hashtags' do
    revision = node_revisions(:hashtag_one)
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    assert_includes tag_names, 'hashtag'
  end

  test 'should ignore hashtags in markdown' do
    revision = node_revisions(:hashtag_one)
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    assert_false tag_names.include?('heading')
  end

  test 'should ignore commas, exclamation, and periods in hashtags' do
    revision = node_revisions(:hashtag_with_punctuation)
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    expected_tags = %w[hashtag1 hashtag2 hashtag3]
    ignore_tags = ['hashtag1,', 'hashtag2!', 'hashtag3.']
    assert_true (expected_tags - tag_names).empty?
    assert_true (ignore_tags - tag_names).length == ignore_tags.length
  end

  test 'should tag hashtags in headers' do
    revision = node_revisions(:hashtag_in_header)
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    assert_includes tag_names, 'hashtags'
  end

  test 'should ignore subheaders' do
    revision = node_revisions(:subheader)
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    assert_false(tag_names.include?('subheader')) || tag_names.include?('#subheader')
  end

  test 'should ignore hashtags in links' do
    revision = node_revisions(:hashtag_in_link)
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    assert_false tag_names.include?('hashtag')
  end

  test 'should ignore hashtags in URLs' do
    revision = node_revisions(:hashtag_in_url)
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    assert_false tag_names.include?('hashtag')
  end

  test 'should not add duplicate tags' do
    revision = node_revisions(:hashtag_three)
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    assert_false tag_names.count('hashtag') > 1
    assert_false tag_names.include?('heading')
  end

  test 'should make the author the tag author' do
    revision = node_revisions(:hashtag_three)
    revision.save
    author = revision.parent.tag.last.node_tag.first.drupal_users
    assert_equal revision.author, author
  end

  test 'should not add duplicate hashtags on update' do
    revision = node_revisions(:hashtag_three)
    revision.save
    revision.body = 'another #hashtag'
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    assert_true tag_names.count('hashtag') == 1
  end

  test 'should remove header from body for preview' do
    revision = node(:one).latest
    revision.body = "##Introduction\n\nThis is my post"
    assert_nil revision.body_preview.match('Introduction')
  end

  test 'should return body if no header for body_preview' do
    revision = node(:one).latest
    revision.body = 'Some stuff about my post'
    assert_true !!revision.body_preview.match('Some stuff about my post')
  end

  test 'should remove header in between two normal paragraphs' do
    revision = node(:one).latest
    revision.body = "Some stuff about my post\n##A title\nsome more stuff about my post"
    assert_nil revision.body_preview.match('A title')
  end

  test 'should change ##header into ## header' do
    revision = node(:one).latest
    revision.body = "Some stuff about my post\n##A title\nsome more stuff about my post"
    assert_equal "Some stuff about my post\n## A title\nsome more stuff about my post", revision.body_rich
  end
end
