require 'test_helper'
require 'byebug'
class RoomChannelTest < ActionCable::Channel::TestCase
  def test_subscription_to_room_channel
    # Simulate a subscription creation to room_channel
    subscribe

    # Asserts that the subscription was successfully created
    assert subscription.confirmed?

    # Asserts that the channel subscribes connection to a stream
    assert_has_stream "room_channel"
  end

  def test_performed_speak_with_no_broadcasts_for_non_admin_user
    # Simulate a subscription creation to room_channel
    stub_connection(current_user: users(:naman))

    # Simulate a subscription creation to room_channel
    subscribe

    # Asserts that the subscription was successfully created
    assert subscription.confirmed?

    # Asserts that the channel subscribes connection to a stream
    assert_has_stream "room_channel"

    assert_no_broadcasts"room_channel" do
      perform :speak, message: "Room Channel Tests"
    end

  end

  def test_performed_speak__with_broadcasts_for_admin_user
    # Simulate a subscription creation to room_channel
    stub_connection(current_user: users(:jeff))

    # Simulate a subscription creation to room_channel
    subscribe

    # Asserts that the subscription was successfully created
    assert subscription.confirmed?

    # Asserts that the channel subscribes connection to a stream
    assert_has_stream "room_channel"

    message = "Room Channel Tests"

    assert_broadcast_on "room_channel", message: message do
      perform :speak, message: message
    end

  end
end