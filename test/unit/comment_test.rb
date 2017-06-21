require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  test 'should save comment' do
    comment = Comment.new
    comment.comment = "My first thought is\n\nthat this is pretty good."
    assert comment.save
  end

  test 'should not save comment without body' do
    comment = Comment.new
    assert !comment.save, 'Saved the comment without body text'
  end

  test 'should scan callouts out of body' do
    comment = Comment.new(nid: node(:one).nid,
                          uid: rusers(:bob).id)
    comment.comment = 'Hey, @Bob, what do you think?'
    assert_not_nil comment
    assert_equal 1, comment.mentioned_users.length
    assert_equal comment.mentioned_users.first.id, rusers(:bob).id
  end

  test 'should scan multiple callouts out of body' do
    comment = Comment.new(nid: node(:one).nid,
                          uid: rusers(:bob).id)
    comment.comment = 'Hey, @Bob, @jeff, @Bob, what do you think?'
    assert_equal comment.mentioned_users.length, 2 # one duplicate, removed
    assert_equal comment.mentioned_users.first.id, rusers(:bob).id
    assert_equal comment.mentioned_users[1].id, rusers(:jeff).id
  end

  test 'should scan multiple space-separated callouts out of body' do
    comment = Comment.new(nid: node(:one).nid,
                          uid: rusers(:bob).id)
    comment.comment = 'Hey, @Bob @jeff @Bob, what do you think?'
    assert_equal comment.mentioned_users.length, 2 # one duplicate, removed
    assert_equal comment.mentioned_users[0].id, rusers(:bob).id
    assert_equal comment.mentioned_users[1].id, rusers(:jeff).id
  end

  test 'should scan hashtags out of body' do
    comment = Comment.new(nid: node(:one).nid,
                          uid: rusers(:bob).id)
    comment.comment = 'Hey, #everything followers.'
    assert_not_nil comment
    assert_equal 1, comment.followers_of_mentioned_tags.length
    assert_equal comment.followers_of_mentioned_tags.first.id, rusers(:moderator).id
    # tag followers can be found in tag_selection.yml
  end

  test 'should scan multiple hashtags out of body' do
    comment = Comment.new(nid: node(:one).nid,
                          uid: rusers(:bob).id)
    comment.comment = 'Hey, #everything, #awesome followers.'
    assert_equal comment.followers_of_mentioned_tags.length, 3
    assert comment.followers_of_mentioned_tags.collect(&:id).include?(rusers(:bob).id)
    assert comment.followers_of_mentioned_tags.collect(&:id).include?(rusers(:moderator).id)
  end

  test 'should scan multiple space-separated hashtags out of body' do
    comment = Comment.new(nid: node(:one).nid,
                          uid: rusers(:bob).id)
    comment.comment = 'Hey, #everything #awesome followers.'
    # assert_equal comment.followers_of_mentioned_tags.length, 2
    assert comment.followers_of_mentioned_tags.collect(&:id).include?(rusers(:bob).id)
    assert comment.followers_of_mentioned_tags.collect(&:id).include?(rusers(:moderator).id)
  end

  test 'should scan hashtags in comments and link them' do
    comment = Comment.new(nid: node(:one).nid,
                          uid: rusers(:bob).id)
    comment.comment = 'This is a test #hashtag'
    assert_equal comment.body, 'This is a test [#hashtag](/tag/hashtag)'
  end

  test 'should ignore Headers as hashtags in markdown' do
    comment = Comment.new(nid: node(:one).nid,
                          uid: rusers(:bob).id)
    comment.comment = '#This is a Heading'
    assert_not_equal comment.body, '[#This](/tag/This) is a Heading'
  end

  test 'should ignore commas, exclamation, periods in hashtag' do
    comment = Comment.new(nid: node(:one).nid,
                          uid: rusers(:bob).id)
    comment.comment = 'Testing #tagnames with #commas, #exclamations! and #periods.'
    assert_includes comment.body, '[#tagnames](/tag/tagnames)'
    assert_not_includes comment.body, '[#commas,](/tag/commas,)'
    assert_not_includes comment.body, '[#exclamations!](/tag/exclamations!)'
    assert_not_includes comment.body, '[#periods.](/tag/periods.)'
  end

  test 'should link hashtags in headers' do
    comment = Comment.new(nid: node(:one).nid,
                          uid: rusers(:bob).id)
    comment.comment = '#Titles and #tagnames'
    assert_equal comment.body, '#Titles and [#tagnames](/tag/tagnames)'
  end

  test 'should ignore sub-headings as hashtags' do
    comment = Comment.new(nid: node(:one).nid,
                          uid: rusers(:bob).id)
    comment.comment = '##Titles'
    assert_not_equal comment.body, '[##Titles](/tag/Titles)'
  end

  test 'should ignore Titles with spaces after hash as hashtags' do
    comment = Comment.new(nid: node(:one).nid,
                          uid: rusers(:bob).id)
    comment.comment = '## Titles'
    assert_not_equal comment.body, '[## Titles](/tag/Titles)'
    comment.comment = '# Tagnames'
    assert_not_equal comment.body, '[# Tagnames](/tag/Tagnames)'
  end

  test 'should ignore hashtag in links as nesting of links is not allowed' do
    comment = Comment.new(nid: node(:one).nid,
                          uid: rusers(:bob).id)
    comment.comment = '[#tags in links](/)'
    assert_not_equal comment.body, '[[#tags](/tag/tags) in links](/)'
  end

  test 'should ignore hashtags in URLs' do
    comment = Comment.new(nid: node(:one).nid,
                          uid: rusers(:bob).id)
    comment.comment = '[tags in URLs](/mypage#tags)'
    assert_not_equal comment.body, '[tags in URLs](/mypage[#tags](/tags/tags))'
  end

  test 'should create comments for answers' do
    answer = answers(:one)
    comment = Comment.new(
      uid: rusers(:bob).id,
      aid: answer.id,
      comment: 'Test comment'
    )
    assert comment.save
  end

  test 'should relate answer comments to user and answer but not node' do
    answer = answers(:one)
    user = users(:bob)
    comment = Comment.new(comment: 'Test comment')
    comment.drupal_users = user
    comment.answer = answer

    assert comment.save
    assert_equal user.comments.last, comment
  end

  test 'should return weekly tallies' do
    Comment.delete_all
    seconds_to_two_weeks_ago = 1_210_000
    seconds_to_four_weeks_ago = seconds_to_two_weeks_ago * 2
    weeks_to_tally = 52
    # placing a comment right before Time.now places it in week 51 so two weeks later is week 49
    two_weeks_ago = weeks_to_tally - 3
    four_weeks_ago = two_weeks_ago - 2
    Comment.create!(comment: 'blah', timestamp: Time.now - 1) # place a comment right before now
    Comment.create!(comment: 'blah', timestamp: Time.now - seconds_to_two_weeks_ago)
    Comment.create!(comment: 'blahblah', timestamp: Time.now - seconds_to_four_weeks_ago)
    weekly_tallies = Comment.comment_weekly_tallies(52)
    assert_equal weekly_tallies[weeks_to_tally - 1], 1
    assert_equal weekly_tallies[two_weeks_ago], 1
    assert_equal weekly_tallies[four_weeks_ago], 1
  end

  test 'should create comments for wiki pages' do
    wiki = node(:wiki_page)
    comment = Comment.new(
      uid: rusers(:bob).id,
      nid: wiki.id,
      comment: 'Test comment for wiki'
    )
    assert comment.save
  end
end
