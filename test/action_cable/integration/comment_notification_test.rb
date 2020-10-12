require 'test_helper'
require 'byebug'
class CommentNotificationTest < ActionDispatch::IntegrationTest
  include ActionCable::TestHelper

  def test_no_broadcasts_when_no_post_request
    node = nodes(:purple_air_with_hyphen)
    notification = Hash.new
    notification[:title] = "New Comment on #{node.title}"
    notification[:path] = node.path
    user_1 = users(:naman18996)
    user_2 = users(:jeffrey)
    body = "Hey, @#{user_1.username} and @#{user_2.username}. This is Action Cable Integration Test"
    option = {
      body: body,
      icon: "https://publiclab.org/logo.png"
    }
    notification[:option] = option

    # Making User Session
    post '/user_sessions', params: { user_session: { username: users(:naman).username, password: 'secretive' } }

    # Test for zero message broadcast
    assert_broadcasts "users:notification:#{user_2.id}", 0
    assert_no_broadcasts "users:notification:#{user_2.id}"

    assert_broadcasts "users:notification:#{user_1.id}", 0
    assert_no_broadcasts "users:notification:#{user_1.id}"
  end

  def test_no_broadcast_when_user_is_not_loggedin
    node = nodes(:purple_air_with_hyphen)
    notification = Hash.new
    notification[:title] = "New Comment on #{node.title}"
    notification[:path] = node.path
    user_1 = users(:naman18996)
    user_2 = users(:jeffrey)
    body = "Hey, @#{user_1.username} and @#{user_2.username}. This is Action Cable Integration Test"
    option = {
      body: body,
      icon: "https://publiclab.org/logo.png"
    }
    notification[:option] = option

    # Checking broadcast integration on comment post request
    assert_no_broadcasts "users:notification:#{user_1.id}" do
      post "/comment/create/#{node.id}", xhr: true, params: { body: body }
    end

    # Checking broadcast integration on comment post request
    assert_no_broadcasts "users:notification:#{user_2.id}" do
      post "/comment/create/#{node.id}", xhr: true, params: { body: body }
    end
  end

  def test_zero_broadcast_when_user_is_not_loggedin
    node = nodes(:purple_air_with_hyphen)
    notification = Hash.new
    notification[:title] = "New Comment on #{node.title}"
    notification[:path] = node.path
    user_1 = users(:naman18996)
    user_2 = users(:jeffrey)
    body = "Hey, @#{user_1.username} and @#{user_2.username}. This is Action Cable Integration Test"
    option = {
      body: body,
      icon: "https://publiclab.org/logo.png"
    }
    notification[:option] = option

    post "/comment/create/#{node.id}", xhr: true, params: { body: body }

    assert_broadcasts "users:notification:#{user_2.id}", 0
    assert_no_broadcasts "users:notification:#{user_2.id}"

    assert_broadcasts "users:notification:#{user_1.id}", 0
    assert_no_broadcasts "users:notification:#{user_1.id}"
  end


  def test_broadcasts_when_user_is_loggedin
    node = nodes(:purple_air_with_hyphen)
    notification = Hash.new
    notification[:title] = "New Comment on #{node.title}"
    notification[:path] = node.path
    user_1 = users(:naman18996)
    user_2 = users(:jeffrey)
    body = "Hey, @#{user_1.username} and @#{user_2.username}. This is Action Cable Integration Test"
    option = {
      body: body,
      icon: "https://publiclab.org/logo.png"
    }
    notification[:option] = option

    # Making User Session
    post '/user_sessions', params: { user_session: { username: users(:naman).username, password: 'secretive' } }

    # Checking broadcast integration on comment post request
    assert_broadcast_on("users:notification:#{user_1.id}", notification: notification) do
      post "/comment/create/#{node.id}", xhr: true, params: { body: body }
    end

    # Checking broadcast integration on comment post request
    assert_broadcast_on("users:notification:#{user_2.id}", notification: notification) do
      post "/comment/create/#{node.id}", xhr: true, params: { body: body }
    end
  end

  def test_number_of_broadcasts_when_user_is_loggedin
    node = nodes(:purple_air_with_hyphen)
    notification = Hash.new
    notification[:title] = "New Comment on #{node.title}"
    notification[:path] = node.path
    user_1 = users(:naman18996)
    user_2 = users(:jeffrey)
    body = "Hey, @#{user_1.username} and @#{user_2.username}. This is Action Cable Integration Test"
    option = {
      body: body,
      icon: "https://publiclab.org/logo.png"
    }
    notification[:option] = option

    # Making User Session
    post '/user_sessions', params: { user_session: { username: users(:naman).username, password: 'secretive' } }

    # Making post comment request
    post "/comment/create/#{node.id}", xhr: true, params: { body: body }

    assert_broadcast_on "users:notification:#{user_1.id}", notification: notification
    assert_broadcasts "users:notification:#{user_2.id}", 1

    assert_broadcast_on "users:notification:#{user_2.id}", notification: notification
    assert_broadcasts "users:notification:#{user_2.id}", 1
  end

  def test_no_broadcast_to_non_engaged_user
    node = nodes(:purple_air_with_hyphen)
    notification = Hash.new
    notification[:title] = "New Comment on #{node.title}"
    notification[:path] = node.path
    user_1 = users(:naman18996)
    user_2 = users(:jeffrey)
    user_3 = users(:steff1)
    body = "Hey, @#{user_1.username} and @#{user_2.username}. This is Action Cable Integration Test"
    option = {
      body: body,
      icon: "https://publiclab.org/logo.png"
    }
    notification[:option] = option

    # Making User Session
    post '/user_sessions', params: { user_session: { username: users(:naman).username, password: 'secretive' } }

    # Making post comment request
    post "/comment/create/#{node.id}", xhr: true, params: { body: body }

    assert_broadcast_on "users:notification:#{user_1.id}", notification: notification
    assert_broadcasts "users:notification:#{user_2.id}", 1

    assert_broadcast_on "users:notification:#{user_2.id}", notification: notification
    assert_broadcasts "users:notification:#{user_2.id}", 1


    assert_broadcasts "users:notification:#{user_3.id}", 0
    assert_no_broadcasts "users:notification:#{user_3.id}"

    assert_no_broadcasts "users:notification:#{user_3.id}" do
      post "/comment/create/#{node.id}", xhr: true, params: { body: body }
    end

    # Checking broadcast integration on comment post request
    assert_broadcast_on("users:notification:#{user_1.id}", notification: notification) do
      post "/comment/create/#{node.id}", xhr: true, params: { body: body }
    end

    # Checking broadcast integration on comment post request
    assert_broadcast_on("users:notification:#{user_2.id}", notification: notification) do
      post "/comment/create/#{node.id}", xhr: true, params: { body: body }
    end

  end

  def test_broadcast_only_to_users_with_notification_all_tag
    node = nodes(:purple_air_with_hyphen)
    notification = Hash.new
    notification[:title] = "New Comment on #{node.title}"
    notification[:path] = node.path
    user_1 = users(:naman18996)
    user_2 = users(:jeffrey)
    user_3 = users(:jeff)
    body = "Hey, @#{user_1.username}, @#{user_2.username} and @#{user_3.username}. This is Action Cable Integration Test"
    option = {
      body: body,
      icon: "https://publiclab.org/logo.png"
    }
    notification[:option] = option

    # Making User Session
    post '/user_sessions', params: { user_session: { username: users(:naman).username, password: 'secretive' } }

    # Making post comment request
    post "/comment/create/#{node.id}", xhr: true, params: { body: body }

    assert_broadcast_on "users:notification:#{user_1.id}", notification: notification
    assert_broadcasts "users:notification:#{user_2.id}", 1

    assert_broadcast_on "users:notification:#{user_2.id}", notification: notification
    assert_broadcasts "users:notification:#{user_2.id}", 1

    assert_no_broadcasts "users:notification:#{user_3.id}"
    assert_broadcasts "users:notification:#{user_3.id}", 0


    assert_no_broadcasts "users:notification:#{user_3.id}" do
      post "/comment/create/#{node.id}", xhr: true, params: { body: body }
    end

    # Checking broadcast integration on comment post request
    assert_broadcast_on("users:notification:#{user_1.id}", notification: notification) do
      post "/comment/create/#{node.id}", xhr: true, params: { body: body }
    end

    # Checking broadcast integration on comment post request
    assert_broadcast_on("users:notification:#{user_2.id}", notification: notification) do
      post "/comment/create/#{node.id}", xhr: true, params: { body: body }
    end
  end

end