require 'test_helper'

class CommentMailerTest < ActionMailer::TestCase
  test 'notify other commenters' do
    user = rusers(:bob)
    comment = comments(:question_one)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      CommentMailer.notify(user, comment).deliver
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal "New comment on '" + comment.parent.title + "'", email.subject
    assert email.body.include?("<p>https://#{request_host}#{comment.parent.path(:question)}#answer-#{comment.aid}-comment-#{comment.cid}</p>")
  end

  test 'notify note author' do
    user = rusers(:jeff)
    comment = comments(:question)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      CommentMailer.notify_note_author(user, comment).deliver
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal "New comment on '" + comment.parent.title + "'", email.subject
    assert email.body.include?("Hi! There's been a comment to your question '<a href='https://#{request_host}#{comment.parent.path(:question)}'>#{comment.parent.title}</a>'")
  end

  test 'notify callout' do
    user = rusers(:bob)
    comment = comments(:question_callout)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      CommentMailer.notify_callout(comment, user)
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal 'You were mentioned in a comment.', email.subject
    assert email.body.include?("Hi! You were mentioned by #{comment.author.name} in a comment on the question <b>#{comment.parent.title}</b>")
  end

  test 'notify tag followers' do
    user = rusers(:bob)
    comment = comments(:question_tag)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      CommentMailer.notify_tag_followers(comment, user)
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal 'A tag you follow was mentioned in a comment.', email.subject
    assert email.body.include?("Hi! A tag you follow was mentioned by #{comment.author.name} in a comment on the question <b>#{comment.parent.title}</b>")
  end

  test 'notify answer author' do
    user = rusers(:bob)
    comment = comments(:answer_comment_one)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      CommentMailer.notify_answer_author(user, comment).deliver
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal "New comment on your answer on '" + comment.parent.title + "'", email.subject
    assert email.body.include?("Hi! There's been a new comment to your answer on '<a href='https://#{request_host}#{comment.parent.path(:question)}#a#{comment.answer.id}'>#{comment.parent.title}</a>'")
  end
end
