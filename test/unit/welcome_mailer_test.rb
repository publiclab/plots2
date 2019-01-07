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

  test 'verification of email' do
    user = users(:admin)
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      WelcomeMailer.send_verification_email(user).deliver_now
    end
    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ["notifications@#{ActionMailer::Base.default_url_options[:host]}"], email.from
    assert_equal [user.email], email.to
    assert_equal "Email verification", email.subject
  end
end
