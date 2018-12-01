require 'test_helper'
class CommentTest < ActiveSupport::TestCase
  test 'should save comment' do
    comment = Comment.new
    comment.comment = "My first thought is\n\nthat this is pretty good. **markdown** and http://link.com"
    assert comment.save
    assert comment.body_markdown.match('<a href="http://link.com">http://link.com</a>')
    assert comment.body_markdown.match('<strong>markdown</strong>')
  end

  test 'comment mysql native fulltext search' do
    assert Comment.count > 0
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      comments = Comment.search('Moderator')
      assert_not_nil comments
      assert comments.length > 0
    end
  end

  test 'should not save comment without body' do
    comment = Comment.new
    assert !comment.save, 'Saved the comment without body text'
  end

  test 'should scan callouts out of body' do
    comment = Comment.new(nid: nodes(:one).nid,
                          uid: users(:bob).id)
    comment.comment = 'Hey, @Bob, what do you think?'
    assert_not_nil comment
    assert_equal 1, comment.mentioned_users.length
    assert_equal comment.mentioned_users.first.id, users(:bob).id
  end

  test 'should scan multiple callouts out of body' do
    comment = Comment.new(nid: nodes(:one).nid,
                          uid: users(:bob).id)
    comment.comment = 'Hey, @Bob, @jeff, @Bob, what do you think?'
    assert_equal comment.mentioned_users.length, 2 # one duplicate, removed
    assert_equal comment.mentioned_users.first.id, users(:bob).id
    assert_equal comment.mentioned_users[1].id, users(:jeff).id
  end

  test 'should scan multiple space-separated callouts out of body' do
    comment = Comment.new(nid: nodes(:one).nid,
                          uid: users(:bob).id)
    comment.comment = 'Hey, @Bob @jeff @Bob, what do you think?'
    assert_equal comment.mentioned_users.length, 2 # one duplicate, removed
    assert_equal comment.mentioned_users[0].id, users(:bob).id
    assert_equal comment.mentioned_users[1].id, users(:jeff).id
  end

  test 'should scan hashtags out of body' do
    comment = Comment.new(nid: nodes(:one).nid,
                          uid: users(:bob).id)
    comment.comment = 'Hey, #everything followers.'
    assert_not_nil comment
    assert_equal 1, comment.followers_of_mentioned_tags.length
    assert_equal comment.followers_of_mentioned_tags.first.id, users(:moderator).id
    # tag followers can be found in tag_selection.yml
  end

  test 'should scan multiple hashtags out of body' do
    comment = Comment.new(nid: nodes(:one).nid,
                          uid: users(:bob).id)
    comment.comment = 'Hey, #everything, #awesome followers.'
    assert_equal comment.followers_of_mentioned_tags.length, 3
    assert comment.followers_of_mentioned_tags.collect(&:id).include?(users(:bob).id)
    assert comment.followers_of_mentioned_tags.collect(&:id).include?(users(:moderator).id)
    assert comment.followers_of_mentioned_tags.collect(&:id).include?(users(:unbanned_spammer).id)
  end

  test 'should scan multiple space-separated hashtags out of body' do
    comment = Comment.new(nid: nodes(:one).nid,
                          uid: users(:bob).id)
    comment.comment = 'Hey, #everything #awesome followers.'
    # assert_equal comment.followers_of_mentioned_tags.length, 2
    assert comment.followers_of_mentioned_tags.collect(&:id).include?(users(:bob).id)
    assert comment.followers_of_mentioned_tags.collect(&:id).include?(users(:moderator).id)
  end

  test 'should scan hashtags in comments and link them' do
    comment = Comment.new(nid: nodes(:one).nid,
                          uid: users(:bob).id)
    comment.comment = 'This is a test #hashtag'
    assert_equal comment.body, 'This is a test [#hashtag](/tag/hashtag)'
  end

  test 'should ignore Headers as hashtags in markdown' do
    comment = Comment.new(nid: nodes(:one).nid,
                          uid: users(:bob).id)
    comment.comment = '#This is a Heading'
    assert_not_equal comment.body, '[#This](/tag/This) is a Heading'
  end

  test 'should ignore commas, exclamation, periods in hashtag' do
    comment = Comment.new(nid: nodes(:one).nid,
                          uid: users(:bob).id)
    comment.comment = 'Testing #tagnames with #commas, #exclamations! and #periods.'
    assert_includes comment.body, '[#tagnames](/tag/tagnames)'
    assert_not_includes comment.body, '[#commas,](/tag/commas,)'
    assert_not_includes comment.body, '[#exclamations!](/tag/exclamations!)'
    assert_not_includes comment.body, '[#periods.](/tag/periods.)'
  end

  test 'should link hashtags in headers' do
    comment = Comment.new(nid: nodes(:one).nid,
                          uid: users(:bob).id)
    comment.comment = '#Titles and #tagnames'
    assert_equal comment.body, '#Titles and [#tagnames](/tag/tagnames)'
  end

  test 'should ignore sub-headings as hashtags' do
    comment = Comment.new(nid: nodes(:one).nid,
                          uid: users(:bob).id)
    comment.comment = '##Titles'
    assert_not_equal comment.body, '[##Titles](/tag/Titles)'
  end

  test 'should ignore Titles with spaces after hash as hashtags' do
    comment = Comment.new(nid: nodes(:one).nid,
                          uid: users(:bob).id)
    comment.comment = '## Titles'
    assert_not_equal comment.body, '[## Titles](/tag/Titles)'
    comment.comment = '# Tagnames'
    assert_not_equal comment.body, '[# Tagnames](/tag/Tagnames)'
  end

  test 'should ignore hashtag in links as nesting of links is not allowed' do
    comment = Comment.new(nid: nodes(:one).nid,
                          uid: users(:bob).id)
    comment.comment = '[#tags in links](/)'
    assert_not_equal comment.body, '[[#tags](/tag/tags) in links](/)'
  end

  test 'should ignore hashtags in URLs' do
    comment = Comment.new(nid: nodes(:one).nid,
                          uid: users(:bob).id)
    comment.comment = '[tags in URLs](/mypage#tags)'
    assert_not_equal comment.body, '[tags in URLs](/mypage[#tags](/tags/tags))'
  end

  test 'should create comments for answers' do
    answer = answers(:one)
    comment = Comment.new(
      uid: users(:bob).id,
      aid: answer.id,
      comment: 'Test comment'
    )
    assert comment.save
  end

  test 'should relate answer comments to user and answer but not node' do
    answer = answers(:one)
    user = drupal_users(:bob)
    comment = Comment.new(comment: 'Test comment')
    comment.drupal_user = user
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
    wiki = nodes(:wiki_page)
    comment = Comment.new(
      uid: users(:bob).id,
      nid: wiki.id,
      comment: 'Test comment for wiki'
    )
    assert comment.save
  end

  test 'should return a list of node commenter uids' do
    comment = comments(:third)

    assert_equal [users(:spammer).uid, users(:jeff).uid], comment.parent_commenter_uids
  end

  test 'should return a list of node liker uids' do
    comment = comments(:third)

    assert_equal [users(:bob).uid], comment.parent_liker_uids
  end

  test 'should return a list of node reviser uids' do
    comment = comments(:third)

    assert_equal [users(:jeff).uid], comment.parent_reviser_uids
  end

  test 'should return a combined list of all commenter, liker, and reviser uids for node' do
    comment = comments(:third)

    assert_equal [users(:spammer).uid, users(:jeff).uid, users(:bob).uid], comment.uids_to_notify
  end

  test 'should return list of users who reacted on a comment' do
    comment = comments(:first)
    user = users(:bob)
    like = Like.create(likeable_id: comment.id, user_id: user.id, likeable_type: "Comment", emoji_type: "Heart")
    map = comment.user_reactions_map
    assert_equal map["Heart"], "Bob reacted with heart emoji"
    like = Like.create(likeable_id: comment.id, user_id: users(:jeff).id, likeable_type: "Comment", emoji_type: "Heart")
    map = comment.user_reactions_map
    assert_equal map["Heart"], "Bob and jeff reacted with heart emoji"
  end


  test 'should parse incoming mail from gmail service correctly and add comment' do
    require 'mail'
    mail = Mail.read('test/fixtures/incoming_test_emails/gmail/incoming_gmail_email.eml')
    node = Node.last
    mail.subject = "Re: #{node.title} (##{node.nid})"
    Comment.receive_mail(mail)
    f = File.open('test/fixtures/incoming_test_emails/gmail/final_parsed_comment.txt', 'r')
    comment = Comment.last
    user_email = mail.from.first
    assert_equal comment.comment, f.read
    assert_equal comment.nid, node.id
    assert_equal comment.message_id, mail.message_id
    assert_equal comment.comment_via, 1
    assert_equal User.find(comment.uid).email, user_email
    f.close()
  end

  test 'should parse text containing "On ____ <email@email.com> wrote:" from comments on display' do
    node = Node.last
    comment = Comment.new({
      comment: "Thank you! On Tuesday, 3 July 2018, 11:20:57 PM IST, RP <rp@email.com> wrote:  Here you go."
    })
    parsed = comment.parse_quoted_text
    assert_equal "Thank you! ", parsed[:body]
    assert_equal "On Tuesday, 3 July 2018, 11:20:57 PM IST, RP <rp@email.com> wrote:", parsed[:boundary]
    assert_equal "  Here you go.", parsed[:quote]
    assert_equal "Thank you! ", comment.scrub_quoted_text
    assert_equal "Thank you! <!-- @@$$%% Trimmed Content @@$$%% -->On Tuesday, 3 July 2018, 11:20:57 PM IST, RP <rp@email.com> wrote:  Here you go.", comment.render_body
  end

  test 'should give the domain of gmail correctly' do
    domain = Comment.get_domain("01namangupta@gmail.com")
    assert_equal domain, "gmail"
  end

  test 'should give the domain of yahoo mail correctly' do
    domain = Comment.get_domain("naman18996@yahoo.com")
    assert_equal domain, "yahoo"
  end

  test 'should be true when there is trimmed content in comment' do
    comment = Comment.new
    f = File.open('test/fixtures/incoming_test_emails/gmail/final_parsed_comment.txt', 'r')
    comment.comment = f.read
    f.close()
    comment.save
    assert_equal true, comment.trimmed_content?
  end

  test 'should be false when there is no trimmed content in comment' do
    comment = Comment.new
    comment.comment = "This is a comment without trimmed content"
    comment.save
    assert_equal false, comment.trimmed_content?
  end

  test 'should parse incoming mail from other domain who use gmail service correctly and add answer comment' do
    require 'mail'
    mail = Mail.read('test/fixtures/incoming_test_emails/gmail/incoming_gmail_email.eml')
    answer = Answer.last
    mail.subject = "Re: (#a#{answer.id})"
    mail.from = ["jeff@publiclab.org"]
    Comment.receive_mail(mail)
    f = File.open('test/fixtures/incoming_test_emails/gmail/final_parsed_comment.txt', 'r')
    comment = Comment.last
    assert_equal comment.comment, f.read
    assert_equal comment.aid, answer.id
    assert_equal comment.message_id, mail.message_id
    assert_equal comment.comment_via, 1
    assert_equal User.find(comment.uid).email, "jeff@publiclab.org"
    f.close()
  end



end
