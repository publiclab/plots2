# In Rails 4, this would be moved to /test/mailers/
require "test_helper"
 
class SubscriptionMailerTest < ActionMailer::TestCase
  test "notify subscribers on creation of a research note" do
    node1 = node(:one)
    subscribers = Tag.subscribers(node1.tags)
    assert_difference 'ActionMailer::Base.deliveries.size', subscribers.size do
      SubscriptionMailer.notify_node_creation(node1)
    end
    assert !ActionMailer::Base.deliveries.empty?
    
    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [subscribers.values.last[:user].email], email.to
    assert_equal "[PublicLab] " + node1.title, email.subject
    assert email.body.include?("Public Lab contributor <a href='https://#{request_host}/profile/#{node1.author.name}'>#{node1.author.name}</a> just posted a new research note")
  end

  test "notify subscribers on creation of a question" do
    node1 = node(:question)
    subscribers = Tag.subscribers(node1.tags)
    assert_difference 'ActionMailer::Base.deliveries.size', subscribers.size do
      SubscriptionMailer.notify_node_creation(node1)
    end
    assert !ActionMailer::Base.deliveries.empty?
    
    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [subscribers.values.last[:user].email], email.to
    assert_equal "[PublicLab] Question: " + node1.title, email.subject
    assert email.body.include?("Public Lab contributor <a href='https://#{request_host}/profile/#{node1.author.name}'>#{node1.author.name}</a> just asked a question")
  end

  test "notify note author when user likes a research note" do
    node1 = node(:one)
    user = rusers(:bob)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      SubscriptionMailer.notify_note_liked(node1, user)
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [node1.author.email], email.to
    assert_equal "[PublicLab] #{user.username} liked your research note", email.subject
    assert email.body.include?("Public Lab contributor #{user.username} (https://#{request_host}/profile/#{user.username}) just liked your research note")
  end

  test "notify question author when user likes a question" do
    node1= node(:question)
    user = rusers(:bob)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      SubscriptionMailer.notify_note_liked(node1, user)
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["do-not-reply@#{request_host}"], email.from
    assert_equal [node1.author.email], email.to
    assert_equal "[PublicLab] #{user.username} liked your question", email.subject
    assert email.body.include?("Public Lab contributor #{user.username} (https://#{request_host}/profile/#{user.username}) just liked your question")
  end
end
