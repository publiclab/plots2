require 'test_helper'

class RevisionsTest < ActiveSupport::TestCase
  test 'create a node_revision' do
    node = Node.new(uid: users(:bob).id,
                    type: 'page')
    node.title = 'My new node for revision testing'
    assert node.save!
    # in testing, uid and id should be matched, although this is not yet true in production db
    node_revision = Revision.new(title: 'My new node',
                                 body: 'My new node',
                                 uid: users(:bob).id,
                                 nid: nodes(:one).nid)
    assert node_revision.save!
    assert_not_equal 0, node_revision.timestamp
    assert_not_nil node_revision.timestamp
  end

  test "create a feature's node_revision" do
    node = Node.new(uid: users(:admin).id,
                    type: 'feature',
                    title: 'footer-feature')
    assert node.save!
    revision = node.new_revision(nid:   node.id,
                                 uid:   users(:admin).uid,
                                 title: 'footer-feature',
                                 body: 'Testing')
    assert revision.save!
    assert_equal 'Testing', revision.body
    assert_equal revision.body, node.latest.body
  end

  test 'spam and republish a revision' do
    revision = revisions(:unmoderated_spam_revision)
    assert_equal 1, revision.status
    revision.spam
    assert_equal 0, revision.status
    revision.publish
    assert_equal 1, revision.status
  end

  test 'previous and next revisions' do
    revision = revisions(:about_rev_4)
    # does previous respect status = 1? no.
    Timecop.travel(Time.now + 2.seconds) # revision sorting is by timestamp, so advance the time
    new_revision = revision.parent.new_revision(body:  'New body',
                                                uid:   users(:bob).id)

    assert_difference 'revision.parent.revisions.length', 1 do
      assert new_revision.save
      assert_not_equal revision.timestamp, new_revision.timestamp
    end

    assert_equal new_revision.previous, revision
    assert_equal revision.next, new_revision

    Timecop.travel(Time.now + 2.seconds) # revision sorting is by timestamp, so advance the time
    new_revision_2 = revision.parent.new_revision(body:  'New body 2',
                                                  uid:   users(:bob).id)

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
    revision = revisions(:hashtag_one)
    assert_includes revision.render_body, '<a href="/tag/hashtag">#hashtag</a>'
  end

  test 'should ignore Headers as hashtags in markdown' do
    revision = revisions(:hashtag_two)
    assert_not_includes revision.render_body, '<a href="/tag/Heading 1">#Heading 1</a>'
  end

  test 'should render correct link for images in email' do
    revision = revisions(:email)
    assert_includes revision.render_body_email(request_host), '//i.publiclab.org/system/images/photos/000/016/229/original/admin_tooltip.png'
  end

  test 'should add tags for hashtags' do
    revision = revisions(:hashtag_one)
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    assert_includes tag_names, 'hashtag'
  end

  test 'should ignore hashtags in markdown' do
    revision = revisions(:hashtag_one)
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    assert_not tag_names.include?('heading')
  end

  test 'should ignore commas, exclamation, and periods in hashtags' do
    revision = revisions(:hashtag_with_punctuation)
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    expected_tags = %w[hashtag1 hashtag2 hashtag3]
    ignore_tags = ['hashtag1,', 'hashtag2!', 'hashtag3.']
    assert (expected_tags - tag_names).empty?
    assert (ignore_tags - tag_names).length == ignore_tags.length
  end

  test 'should tag hashtags in headers' do
    revision = revisions(:hashtag_in_header)
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    assert_includes tag_names, 'hashtags'
  end

  test 'should ignore subheaders' do
    revision = revisions(:subheader)
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    assert_not tag_names.include?('subheader') || tag_names.include?('#subheader')
  end

  test 'should ignore hashtags in links' do
    revision = revisions(:hashtag_in_link)
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    assert_not tag_names.include?('hashtag')
  end

  test 'should ignore hashtags in URLs' do
    revision = revisions(:hashtag_in_url)
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    assert_not tag_names.include?('hashtag')
  end

  test 'should not add duplicate tags' do
    revision = revisions(:hashtag_three)
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    assert_not tag_names.count('hashtag') > 1
    assert_not tag_names.include?('heading')
  end

  test 'should make the author the tag author' do
    revision = revisions(:hashtag_three)
    revision.save
    author = revision.parent.tag.last.node_tag.first.user
    assert_equal revision.author, author
  end

  test 'should not add duplicate hashtags on update' do
    revision = revisions(:hashtag_three)
    revision.save
    revision.body = 'another #hashtag'
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    assert tag_names.count('hashtag') == 1
  end

  test 'should remove header from body for preview' do
    revision = nodes(:one).latest
    revision.body = "##Introduction\n\nThis is my post"
    assert_nil revision.body_preview.match('Introduction')
  end

  test 'should return body if no header for body_preview' do
    revision = nodes(:one).latest
    revision.body = 'Some stuff about my post'
    assert !!revision.body_preview.match('Some stuff about my post')
  end

  test 'should remove header in between two normal paragraphs' do
    revision = nodes(:one).latest
    revision.body = "Some stuff about my post\n##A title\nsome more stuff about my post"
    assert_nil revision.body_preview.match('A title')
  end

  test 'should change ##header into ## header' do
    revision = nodes(:one).latest
    revision.body = "Some stuff about my post\n##A title\nsome more stuff about my post"
    assert_equal "Some stuff about my post\n## A title\nsome more stuff about my post", revision.body_rich
  end

  test 'should not add tag when pure number is present' do
    revision = revisions(:hashtag_four)
    revision.save
    associated_tags = revision.parent.tag
    tag_names = associated_tags.map(&:name)
    assert_not tag_names.include?('1234')
  end

  test 'should recognize unmarked markdown style checkboxes and convert them into unchecked checkbox' do
    revision = revisions(:checkbox_one)
    assert_includes revision.render_body, %(* <input type="checkbox" editable="false" />)
  end

  test 'should recognize marked markdown style checkboxes and convert them into checked checkbox' do
    revision = revisions(:checkbox_two)
    assert_includes revision.render_body, %(* <input type="checkbox" editable="false" checked="checked" />)
  end


end
