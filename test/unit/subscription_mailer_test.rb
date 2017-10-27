# In Rails 4, this would be moved to /test/mailers/
require 'test_helper'

class SubscriptionMailerTest < ActionMailer::TestCase
  test 'notify subscribers on creation of a research note' do
    node = node(:one)
    subscribers = Tag.subscribers(node.tags)
    assert_difference 'ActionMailer::Base.deliveries.size', subscribers.size do
      SubscriptionMailer.notify_node_creation(node)
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [subscribers.values.last[:user].email], email.to
    assert_equal '[PublicLab] ' + node.title, email.subject
    assert email.body.include?("Public Lab contributor <a href='https://#{request_host}/profile/#{node.author.name}'>#{node.author.name}</a> just posted a new research note")
  end

  test 'notify subscribers on creation of a question' do
    node = node(:question)
    subscribers = Tag.subscribers(node.tags)
    assert_difference 'ActionMailer::Base.deliveries.size', subscribers.size do
      SubscriptionMailer.notify_node_creation(node)
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [subscribers.values.last[:user].email], email.to
    assert_equal '[PublicLab] Question: ' + node.title, email.subject
    assert email.body.include?("Public Lab contributor <a href='https://#{request_host}/profile/#{node.author.name}'>#{node.author.name}</a> just asked a question")
  end

  test 'notify note author when user likes a research note' do
    node = node(:one)
    user = rusers(:bob)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      SubscriptionMailer.notify_note_liked(node, user)
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [node.author.email], email.to
    assert_equal "[PublicLab] #{user.username} liked your research note", email.subject
    assert email.body.include?("Public Lab contributor #{user.username} (https://#{request_host}/profile/#{user.username}) just liked your research note")
  end

  test 'notify question author when user likes a question' do
    node = node(:question)
    user = rusers(:bob)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      SubscriptionMailer.notify_note_liked(node, user)
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [node.author.email], email.to
    assert_equal "[PublicLab] #{user.username} liked your question", email.subject
    assert email.body.include?("Public Lab contributor #{user.username} (https://#{request_host}/profile/#{user.username}) just liked your question")
  end

  test 'notify users who follow a newly added tag but were not previously notified based on the node existing tags' do
    node = node(:one)
    node_tags = node.tags
    new_tag = tags(:spam)
    user = users(:spammer)
    users_not_following_tags = new_tag.followers_who_dont_follow_tags(node_tags)
    users_to_email = users_not_following_tags.reject { |u| u.uid == user.uid }
    u_e = Tag.followers('everything')
    assert !u_e.empty?
    users_to_email_without_exception = users_to_email.reject { |u| u_e.include? u }
    assert_difference 'ActionMailer::Base.deliveries.size', users_to_email_without_exception.count do
      SubscriptionMailer.notify_tag_added(node, new_tag, user)
    end
    assert !ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [users_to_email.last.email], email.to
    assert_not_equal [user.email], email.to
    assert_equal "New tag added on #{node.title}", email.subject
    assert email.body.include?("Public Lab contributor <a href='https://#{request_host}/profile/#{user.username}'>#{user.username}</a> just added a tag")
  end
end
