require 'test_helper'

class AnswerMailerTest < ActionMailer::TestCase
  test 'notify question author' do
    user = users(:jeff)
    answer = answers(:one)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      AnswerMailer.notify_question_author(user, answer).deliver_now
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["notifications@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal '[PLab] Question: ' + answer.node.title.truncate(30, omission: '...?') + ' An answer has been posted on Public Lab' + + " (#a#{answer.id})", email.subject
    assert email.body.include?("Hi! <a href='https://#{request_host}/profile/#{answer.author.name}'>#{answer.author.name}</a> responded :
<hr /><p>#{answer.content}</p><hr />")
  end

  test 'notify other answer authors' do
    user = users(:bob)
    answer = answers(:two)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      AnswerMailer.notify_answer_likers_author(user, answer).deliver_now
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["notifications@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal '[PublicLab] New answer to Question: ' + answer.node.title + " (#a#{answer.id})", email.subject
    assert email.body.include?("Hi! There's been a new answer posted for the question '<a href='https://#{request_host}#{answer.node.path(:question)}'>#{answer.node.title}</a>' that you also answered")
  end

  test 'notify user who liked the question' do
    user = users(:admin)
    answer = answers(:two)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      AnswerMailer.notify_answer_likers_author(user, answer).deliver_now
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["notifications@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal "[PublicLab] New answer to Question: " + answer.node.title + " (#a#{answer.id})", email.subject
    assert email.body.include?("Hi! There's been a new answer posted for the question '<a href='https://#{request_host}#{answer.node.path(:question)}'>#{answer.node.title}</a>' that you liked")
  end

  test 'notify answer author when answer is accepted' do
    user = users(:bob)
    answer = answers(:one)

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      AnswerMailer.notify_answer_accept(user, answer).deliver_now
    end

    assert_not ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    answer_accepted = '[PublicLab] Your answer has been accepted'
    answer_for_question = "Your answer for the question <a href='https://#{request_host}#{answer.node.path(:question)}'>#{answer.node.title}</a> has been accepted"

    assert_equal ["notifications@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal answer_accepted, email.subject
    assert email.body.include?(answer_for_question)
  end

  test 'notify answer author when answer is liked' do
    user = users(:bob)
    answer = answers(:one)

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      AnswerMailer.notify_answer_like(user, answer).deliver_now
    end

    assert_not ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["notifications@#{request_host}"], email.from
    assert_equal [answer.author.email], email.to
    assert_equal "[PublicLab] #{user.username} liked your answer to: " + answer.node.title + " (#a#{answer.id})", email.subject
    assert email.body.include?("Public Lab contributor <a href='https://#{request_host}/profile/#{user.username}'>#{user.username}</a> just liked your answer to the question <a href='https://#{request_host}#{answer.node.path(:question)}'>#{answer.node.title}</a>")
  end
end
