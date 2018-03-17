# In Rails 4, this would be moved to /test/mailers/
require 'test_helper'
include ActionView::Helpers::DateHelper # required for time_ago_in_words()

class AdminMailerTest < ActionMailer::TestCase
  test 'notify_node_moderators' do
    node = nodes(:one)
    moderators = User.where(role: %w[moderator admin])
    assert !moderators.empty?

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      # send the email
      AdminMailer.notify_node_moderators(node)
    end

    # test that it got queued
    assert !ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last

    assert_not_nil email.to
    assert_not_nil email.bcc
    assert_equal ["moderators@#{request_host}"], ActionMailer::Base.deliveries.last.to
    assert_equal moderators.collect(&:email), ActionMailer::Base.deliveries.last.bcc
    assert_equal '[New Public Lab poster needs moderation] ' + node.title, email.subject
    assert email.body.include?("First-time poster <a href='https://#{request_host}/profile/#{node.author.name}'>#{node.author.name}</a> has submitted their first research note!")
    assert email.body.include?(node.latest.render_body_email(request_host))
  end

  test 'notify_author_of_approval' do
    node = nodes(:one)
    moderator = users(:moderator)

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      # send the email
      AdminMailer.notify_author_of_approval(node, moderator)
    end

    # test that it got queued
    assert !ActionMailer::Base.deliveries.empty?

    # test the last one
    email = ActionMailer::Base.deliveries.last
    assert_not_nil email.to
    assert_equal [node.author.mail], email.to
    assert_equal '[Public Lab] Your post was approved!', email.subject
    assert email.body.include?("Hi! Your post was approved by <a href='https://#{request_host}/profile/#{moderator.username}'>#{moderator.username}</a> (a <a href='https://#{request_host}/wiki/moderation'>community moderator</a>) and is now visible in the <a href='https://#{request_host}/dashboard'>Public Lab research feed</a>. Thanks for contributing to open research!")
  end

  test 'notify_moderators_of_approval' do
    node = nodes(:one)
    moderator = users(:moderator) # who actually approved the post
    moderators = User.where(role: %w[moderator admin])
    assert !moderators.empty?

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      # send the email
      AdminMailer.notify_moderators_of_approval(node, moderator)
    end

    # test that it got queued
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_not_nil email.to
    assert_not_nil email.bcc
    assert_equal ["moderators@#{request_host}"], ActionMailer::Base.deliveries.last.to
    assert_equal moderators.collect(&:email), ActionMailer::Base.deliveries.last.bcc
    # title same as initial for email client threading
    assert_equal '[New Public Lab poster needs moderation] ' + node.title, email.subject
    time_ago = time_ago_in_words(node.created_at)
    assert email.body.include?("Post was approved by <a href='https://#{request_host}/profile/#{moderator.username}'>#{moderator.username}</a> after entering moderation queue #{time_ago} ago and is now visible in the <a href='https://#{request_host}/dashboard'>Public Lab research feed</a>. Thanks for helping to keep Public Lab a welcoming and spam-free space!")
  end

  # Should: prompt moderators to reach out if it's not spam, but a guidelines violation
  test 'notify_moderators_of_spam' do
    node = nodes(:one)
    moderator = users(:moderator) # who actually approved the post
    moderators = User.where(role: %w[moderator admin])
    assert !moderators.empty?

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      # send the email
      AdminMailer.notify_moderators_of_spam(node, moderator)
    end

    # test that it got queued
    assert !ActionMailer::Base.deliveries.empty?

    # test the last one
    email = ActionMailer::Base.deliveries.last
    assert_not_nil email.to
    assert_not_nil email.bcc
    assert_equal ["moderators@#{request_host}"], ActionMailer::Base.deliveries.last.to
    assert_equal moderators.collect(&:email), ActionMailer::Base.deliveries.last.bcc
    # title same as initial for email client threading
    assert_equal '[New Public Lab poster needs moderation] ' + node.title, email.subject
    time_ago = time_ago_in_words(node.created_at)
    assert email.body.include?("Post was marked as spam by <a href='https://#{request_host}/profile/#{moderator.username}'>#{moderator.username}</a> after entering moderation queue #{time_ago} ago.")
  end
end
