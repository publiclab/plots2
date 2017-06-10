require 'test_helper'

class SubscriptionMailerTest < ActionMailer::TestCase
  test "notify_tag_added" do
    mail = SubscriptionMailer.notify_tag_added(user = User.first, node = Node.first)
    assert_equal "New Tag Added", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["do-not-reply@www.example.com"], mail.from
    assert_match user.username, mail.body.encoded
  end

end
