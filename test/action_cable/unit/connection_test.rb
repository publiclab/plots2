require 'test_helper'
require 'byebug'
module ApplicationCable
  class ConnectionTest < ActionCable::Connection::TestCase

    def test_connects_and_current_user_with_cookies

      user = users(:naman)
      cookies.signed[:user_token] = user.persistence_token

      # Simulate a connection
      connect

      # Asserts that the connection identifier is correct
      assert_equal user, connection.current_user
      assert_equal user.id, connection.current_user.id
      assert_equal user.name, connection.current_user.name
    end

    def test_connects_and_nil_current_user_with_wrong_cookies
      cookies.signed[:user_token] = SecureRandom.hex

      # Simulate a connection
      connect

      # Asserts that the connection identifier is correct
      assert_equal nil, connection.current_user
    end

    def test_connects_and_nil_current_user_with_no_cookies
      # Simulate a connection
      connect

      # Asserts that the connection identifier is correct
      assert_equal nil, connection.current_user
    end

  end
end
