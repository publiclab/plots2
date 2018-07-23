require 'test_helper'

class WelcomeMailerTest < ActionMailer::TestCase

  test 'notify newcomer with welcome email' do
    user = users(:bob)
    @body = nodes(:welcome_feature)

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      WelcomeMailer.notify_newcomer(user).deliver_now
    end
    assert !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries.last
    assert_equal ["notifications@#{request_host}"], email.from
    assert_equal [user.email], email.to
    assert_equal "Welcome to Public Lab", email.subject
    assert email.body.include?("Welcome to Public Lab")
  end
end
