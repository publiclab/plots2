require 'test_helper'

class SubscriptionMailerTest < ActionMailer::TestCase
  test "notify_tag_added" do
    mail = SubscriptionMailer.notify_tag_added
    assert_equal "Notify tag added", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
