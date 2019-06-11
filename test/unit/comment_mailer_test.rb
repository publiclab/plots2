require 'test_helper'

class CommentMailerTest < ActionMailer::TestCase
  test 'notify other commenters' do
    user = users(:bob)
    comment = comments(:question_one)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      CommentMailer.notify(user, comment).deliver_now
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["notifications@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal "New comment on #{comment.parent.title} (##{comment.parent.id}) ", email.subject
    assert email.body.include?("<p>https://#{request_host}#{comment.parent.path(:question)}#answer-#{comment.aid}-comment-#{comment.cid}</p>")
  end

  test 'notify note author' do
    user = users(:jeff)
    comment = comments(:question)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      CommentMailer.notify_note_author(user, comment).deliver_now
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["notifications@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal "New comment on #{comment.parent.title} (##{comment.parent.id}) ", email.subject
    assert email.body.include?("Hi! There's been a comment to your question '<a href='https://#{request_host}#{comment.parent.path(:question)}'>#{comment.parent.title}</a>'")
  end

  test 'notify callout' do
    user = users(:bob)
    comment = comments(:question_callout)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      CommentMailer.notify_callout(comment, user).deliver_now
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["notifications@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal "You were mentioned in a comment. (##{comment.parent.id}) ", email.subject
    assert email.body.include?("Hi! You were mentioned by #{comment.author.name} in a comment on the question <b>#{comment.parent.title}</b>")
  end

  test 'notify tag followers' do
    user = users(:bob)
    comment = comments(:question_tag)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      CommentMailer.notify_tag_followers(comment, user).deliver_now
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["notifications@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal "A tag you follow was mentioned in a comment. (##{comment.parent.id}) ", email.subject
    assert email.body.include?("Hi! A tag you follow was mentioned by #{comment.author.name} in a comment on the question <b>#{comment.parent.title}</b>")
  end

 
  test 'notify barnstar' do
    user = users(:bob)
    note = nodes(:one)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      CommentMailer.notify_barnstar(user, note).deliver_now
    end

    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["notifications@#{request_host}"], email.from
    assert_equal [note.author.email], email.to
    assert_equal "You were awarded a Barnstar!", email.subject
    assert email.body.include?("'<a href='https://#{request_host}/profile/#{user.name}'>#{user.name}</a>' has awarded you a '<a href='https://#{request_host}/wiki/barnstars'>Barnstar</a>' for your work in the research note '<a href='https://#{request_host}#{note.path}'>#{note.title}</a>'")
  end
  
  test 'notify coauthor' do
    user = users(:bob)
    note = nodes(:one)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      CommentMailer.notify_coauthor(user, note).deliver_now
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["notifications@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal "You were added as a co-author!", email.subject
    assert email.body.include?("'<a href='https://#{request_host}/profile/#{note.author.name}'>#{note.author.name}</a>' has added you as a co-author of '<a href='https://#{request_host}#{note.path}'>#{note.title}</a>'")
  end
 end
