require 'test_helper'

class AnswerMailerTest < ActionMailer::TestCase
  test 'notify question author' do
    user = rusers(:jeff)
    answer = answers(:one)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      AnswerMailer.notify_question_author(user, answer).deliver
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal '[PublicLab] New answer to Question: ' + answer.node.title, email.subject
    assert email.body.include?("Hi! A new answer has been posted for your question '<a href='https://#{request_host}#{answer.node.path(:question)}'>#{answer.node.title}</a>'")
  end

  test 'notify other answer authors' do
    user = rusers(:bob)
    answer = answers(:two)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      AnswerMailer.notify_answer_likers_author(user, answer).deliver
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal '[PublicLab] New answer to Question: ' + answer.node.title, email.subject
    assert email.body.include?("Hi! There's been a new answer posted for the question '<a href='https://#{request_host}#{answer.node.path(:question)}'>#{answer.node.title}</a>' that you also answered")
  end

  test 'notify user who liked the question' do
    user = rusers(:admin)
    answer = answers(:two)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      AnswerMailer.notify_answer_likers_author(user, answer).deliver
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal '[PublicLab] New answer to Question: ' + answer.node.title, email.subject
    assert email.body.include?("Hi! There's been a new answer posted for the question '<a href='https://#{request_host}#{answer.node.path(:question)}'>#{answer.node.title}</a>' that you liked")
  end

  test 'notify answer author when answer is accepted' do
    user = rusers(:bob)
    answer = answers(:one)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      AnswerMailer.notify_answer_accept(user, answer).deliver
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal '[PublicLab] Your answer has been accepted', email.subject
    assert email.body.include?("Your answer for the question <a href='https://#{request_host}#{answer.node.path(:question)}'>#{answer.node.title}</a> has been accepted")
  end

  test 'notify answer author when answer is liked' do
    user = rusers(:bob)
    answer = answers(:one)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      AnswerMailer.notify_answer_like(user, answer).deliver
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [answer.author.email], email.to
    assert_equal "[PublicLab] #{user.username} liked your answer to: " + answer.node.title, email.subject
    assert email.body.include?("Public Lab contributor <a href='https://#{request_host}/profile/#{user.username}'>#{user.username}</a> just liked your answer to the question <a href='https://#{request_host}#{answer.node.path(:question)}'>#{answer.node.title}</a>")
  end
end
