require 'test_helper'
require 'byebug'
class UserChannelTest < ActionCable::Channel::TestCase
  def test_no_subscription_to_user_channel_when_user_is_not_loggedin

    # Setting current_user to nil in stub connection means user is not loggedin
    stub_connection(current_user: nil)

    # Simulate a subscription creation to user_channel
    subscribe

    # Asserts that the subscription was successfully created
    assert subscription.rejected?

    # Asserts that the channel subscribes connection to a stream
    assert_no_streams
  end

  def test_subscription_to_user_channel_when_user_is_loggedin

    # Setting current_user to nil in stub connection means user is not loggedin
    user = users(:naman)
    stub_connection(current_user: user)

    # Simulate a subscription creation to user_channel
    subscribe

    # Asserts that the subscription was successfully created
    assert subscription.confirmed?

    # Asserts that the channel subscribes connection to a stream
    assert_has_stream "users:#{user.id}"
  end
end