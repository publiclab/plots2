require 'test_helper'

class DrupalCommentTest < ActiveSupport::TestCase

  test "should not save comment without body" do
    comment = DrupalComment.new
    assert !comment.save, "Saved the comment without body text"
  end

  test "should scan callouts out of body" do
    comment = DrupalComment.new({
      nid: node(:one).nid,
      uid: rusers(:bob).id
    })
    comment.comment = 'Hey, @Bob, what do you think?'
    assert_not_nil comment
    assert_equal 1, comment.mentioned_users.length
    assert_equal comment.mentioned_users.first.id, rusers(:bob).id
  end

  test "should scan multiple callouts out of body" do
    comment = DrupalComment.new({
      nid: node(:one).nid,
      uid: rusers(:bob).id
    })
    comment.comment = 'Hey, @Bob, @jeff, @Bob, what do you think?'
    assert_equal comment.mentioned_users.length, 2 # one duplicate, removed
    assert_equal comment.mentioned_users.first.id, rusers(:bob).id
    assert_equal comment.mentioned_users[1].id, rusers(:jeff).id
  end

  test "should scan multiple space-separated callouts out of body" do
    comment = DrupalComment.new({
      nid: node(:one).nid,
      uid: rusers(:bob).id
    })
    comment.comment = 'Hey, @Bob @jeff @Bob, what do you think?'
    assert_equal comment.mentioned_users.length, 2 # one duplicate, removed
    assert_equal comment.mentioned_users[0].id, rusers(:bob).id
    assert_equal comment.mentioned_users[1].id, rusers(:jeff).id
  end

  test "should scan hashtags in comments and link them" do
    comment = DrupalComment.new({
      nid: node(:one).nid,
      uid: rusers(:bob).id
    })
    comment.comment = 'This is a test #hashtag'
    assert_equal comment.body, 'This is a test [#hashtag](/tag/hashtag)'
  end

  test "should ignore Headers as hashtags in markdown" do
    comment = DrupalComment.new({
      nid: node(:one).nid,
      uid: rusers(:bob).id
    })
    comment.comment = '#This is a Heading'
    assert_not_equal comment.body, '[#This](/tag/This) is a Heading'
  end

  test "should ignore commas, exclamation, periods in hashtag" do
    comment = DrupalComment.new({
      nid: node(:one).nid,
      uid: rusers(:bob).id
    })
    comment.comment = 'Testing #tagnames with #commas, #exclamations! and #periods.'
    assert_includes comment.body, '[#tagnames](/tag/tagnames)'
    assert_not_includes comment.body, '[#commas,](/tag/commas,)'
    assert_not_includes comment.body, '[#exclamations!](/tag/exclamations!)'
    assert_not_includes comment.body, '[#periods.](/tag/periods.)'
  end

  test "should link hashtags in headers" do
    comment = DrupalComment.new({
      nid: node(:one).nid,
      uid: rusers(:bob).id
    })
    comment.comment = '#Titles and #tagnames'
    assert_equal comment.body, '#Titles and [#tagnames](/tag/tagnames)'
  end

  test "should ignore sub-headings as hashtags" do
    comment = DrupalComment.new({
      nid: node(:one).nid,
      uid: rusers(:bob).id
    })
    comment.comment = '##Titles'
    assert_not_equal comment.body, '[##Titles](/tag/Titles)'
  end

  test "should ignore Titles with spaces after hash as hashtags" do
    comment = DrupalComment.new({
      nid: node(:one).nid,
      uid: rusers(:bob).id
    })
    comment.comment = '## Titles'
    assert_not_equal comment.body, '[## Titles](/tag/Titles)'
    comment.comment = '# Tagnames'
    assert_not_equal comment.body, '[# Tagnames](/tag/Tagnames)'
  end

  test "should ignore hashtag in links as nesting of links is not allowed" do
    comment = DrupalComment.new({
      nid: node(:one).nid,
      uid: rusers(:bob).id
    })
    comment.comment = '[#tags in links](/)'
    assert_not_equal comment.body, '[[#tags](/tag/tags) in links](/)'
  end

  test "should ignore hashtags in URLs" do
    comment = DrupalComment.new({
      nid: node(:one).nid,
      uid: rusers(:bob).id
    })
    comment.comment = '[tags in URLs](/mypage#tags)'
    assert_not_equal comment.body, '[tags in URLs](/mypage[#tags](/tags/tags))'
  end

  test "should create comments for answers" do
    answer = answers(:one)
    comment = DrupalComment.new(
      uid: rusers(:bob).id,
      aid: answer.id,
      comment: 'Test comment'
    )
    assert comment.save
  end

  test "should relate answer comments to user and answer but not node" do
    answer = answers(:one)
    user = users(:bob)
    comment = DrupalComment.new(comment: 'Test comment')
    comment.drupal_users = user
    comment.answer = answer

    assert comment.save
    assert_equal user.drupal_comments.last, comment
    assert_equal answer.drupal_comments.last, comment
    assert_not_equal answer.node.drupal_comments.last, comment
  end

end
