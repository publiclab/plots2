require 'test_helper'

# Using ActionCable::TestCase
class MyCableTest < ActionCable::TestCase

  # Tests for Action Cable Broadcast

  def test_no_broadcasts
    # Test for zero message broadcast
    assert_broadcasts 'messages', 0
    assert_no_broadcasts 'messages'
  end

  def test_broadcast
    ActionCable.server.broadcast 'messages', { text: 'Testing ActionCable' }
    assert_broadcasts 'messages', 1
  end

  def test_broadcast_with_data
    ActionCable.server.broadcast 'messages', { text: 'Testing ActionCable' }
    assert_broadcasts 'messages', 1
    assert_broadcast_on 'messages',{ text: 'Testing ActionCable' }
  end

  def test_multiple_broadcast
    ActionCable.server.broadcast 'messages', { text: 'Testing ActionCable 1' }
    ActionCable.server.broadcast 'messages', { text: 'Testing ActionCable 2' }
    ActionCable.server.broadcast 'messages', { text: 'Testing ActionCable 3' }
    assert_broadcasts 'messages', 3
  end

  def test_multiple_broadcast_with_same_data
    # Test multiple broadcast with same multiple data
    ActionCable.server.broadcast 'messages', { text: 'Testing ActionCable' }
    ActionCable.server.broadcast 'messages', { text: 'Testing ActionCable' }
    ActionCable.server.broadcast 'messages', { text: 'Testing ActionCable' }
    assert_broadcasts 'messages', 3
    assert_broadcast_on 'messages', { text: 'Testing ActionCable' }
  end

  def test_multiple_broadcast_with_differnt_data
    # Test multiple broadcast with differnent multiple data
    ActionCable.server.broadcast 'messages', { text: 'Testing ActionCable 1' }
    ActionCable.server.broadcast 'messages', { text: 'Testing ActionCable 2' }
    ActionCable.server.broadcast 'messages', { text: 'Testing ActionCable 3' }
    assert_broadcasts 'messages', 3
    assert_broadcast_on 'messages', { text: 'Testing ActionCable 1' }
    assert_broadcast_on 'messages', { text: 'Testing ActionCable 2' }
    assert_broadcast_on 'messages', { text: 'Testing ActionCable 3' }
  end

  def test_no_broadcast
    # Check that no broadcasts has been made
    assert_no_broadcasts('messages') do
      ActionCable.server.broadcast 'another_stream', { text: 'Testing ActionCable' }
    end
  end

  def test_different_broadcast
    # Check that only one broadcasts has been made
    assert_broadcasts('messages', 1) do
      ActionCable.server.broadcast 'messages', { text: 'Testing ActionCable' }
      ActionCable.server.broadcast 'another_stream', { text: 'Testing ActionCable' }
    end
  end
end
