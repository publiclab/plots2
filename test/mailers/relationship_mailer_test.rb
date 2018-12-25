require 'test_helper'

class RelationshipMailerTest < ActionMailer::TestCase
  test 'notify upon following' do
    user_follower = User.find_by_username('jeff')
    user_followed = User.find_by_username('Bob')
    email = RelationshipMailer.notify_the_user_who_is_followed(user_followed, user_follower)
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal ["notifications@#{ActionMailer::Base.default_url_options[:host]}"], email.from
    assert_equal [user_followed.email], email.to
  end
end
