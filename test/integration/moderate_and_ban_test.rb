require 'test_helper'

class ModerateAndBanTest < ActionDispatch::IntegrationTest
  test 'users are logged out and alerted when banned, and notes are not accessible' do
    u = users(:unmoderated_user)
    post '/user_sessions', user_session: {
      username: u.username,
      password: 'secretive'
    }

    get '/post' # dashboard is actually world-readable, but /post is not

    assert_response :success

    u.drupal_user.ban

    get '/post' # dashboard is actually world-readable, but /post is not

    follow_redirect!
    # in application_controller.rb; normal logged out message to deter spammers:
    assert_equal 'You must be logged in to access this page', flash[:warning]

    get nodes(:moderated_user_note).path

    assert_response :redirect
    follow_redirect!
    # in application_controller.rb:
    assert_equal 'The author of that note has been banned.', flash[:error]

    get nodes(:question3).path # a Q by unmoderated_user

    assert_response :redirect
    follow_redirect!
    # in application_controller.rb:
    assert_equal 'The author of that note has been banned.', flash[:error]

    get "/profile/#{u.username}"

    assert_response :redirect
    follow_redirect!
    # in application_controller.rb:
    assert_equal I18n.t('users_controller.user_has_been_banned'), flash[:error]

    u.drupal_user.unban

    get nodes(:moderated_user_note).path

    assert_response :success
  end

  test 'users are logged out and alerted when moderated, and notes are not accessible' do
    u = users(:unmoderated_user)
    post '/user_sessions', user_session: {
      username: u.username,
      password: 'secretive'
    }

    get '/post' # dashboard is actually world-readable, but /post is not

    assert_response :success
    u.drupal_user.moderate

    get '/post' # dashboard is actually world-readable, but /post is not

    assert_response :redirect
    follow_redirect!
    # in application_controller.rb:
    assert_equal "The user '#{u.username}' has been placed in moderation; please see <a href='https://#{request_host}/wiki/moderators'>our moderation policy</a> and contact <a href='mailto:moderators@#{request_host}'>moderators@#{request_host}</a> if you believe this is in error.", flash[:warning]

    get nodes(:moderated_user_note).path

    assert_response :success
    assert_equal "The user '#{u.username}' has been placed <a href='https://#{request_host}/wiki/moderators'>in moderation</a> and will not be able to respond to comments.", flash[:warning]

    get nodes(:question3).path # a Q by unmoderated_user

    # this node has path stored as /notes/... not /questions/... so there is a redirect to the questions controller
    assert_response :redirect
    follow_redirect!

    assert_response :success
    # in application_controller.rb:
    assert_equal "The user '#{u.username}' has been placed <a href='https://#{request_host}/wiki/moderators'>in moderation</a> and will not be able to respond to comments.", flash[:warning]

    get "/profile/#{u.username}"

    assert_equal I18n.t('users_controller.user_has_been_moderated'), flash[:warning]
    assert_response :success

    u.drupal_user.unmoderate

    get nodes(:moderated_user_note).path

    assert_response :success
    assert_nil flash[:warning]
  end

  test 'moderated user profiles are not visible when banned' do
    u = users(:unmoderated_user)
    u.drupal_user.ban
    admin = users(:admin)

    post '/user_sessions', user_session: {
      username: admin.username,
      password: 'secretive'
    }

    get "/profile/#{u.username}"

    assert_equal I18n.t('users_controller.user_has_been_banned'), flash[:error]
    assert_response :success
  end

  test 'moderators and admins can moderate others' do
    u = users(:unmoderated_user)
    admin = users(:admin)
    u.drupal_user.unmoderate
    u.drupal_user.unban

    post '/user_sessions', user_session: {
      username: admin.username,
      password: 'secretive'
    }

    get "/admin/moderate/#{u.uid}"

    assert_response :redirect
    follow_redirect!
    assert_equal flash[:notice], 'The user has been moderated.'
    assert_equal u.drupal_user.status, 5

    get "/admin/unmoderate/#{u.uid}"

    assert_response :redirect
    follow_redirect!
    assert_equal flash[:notice], 'The user has been unmoderated.'
    assert_equal u.drupal_user.status, 1
  end

  test 'normal users can not moderate others' do
    u = users(:unmoderated_user)
    normal_user = users(:bob)
    u.drupal_user.unmoderate
    u.drupal_user.unban

    post '/user_sessions', user_session: {
      username: normal_user.username,
      password: 'secretive'
    }

    get "/admin/moderate/#{u.uid}"

    assert_response :redirect
    follow_redirect!
    assert_equal flash[:error], 'Only moderators can moderate other users.'
    assert_equal u.drupal_user.status, 1

    u.drupal_user.moderate

    get "/admin/unmoderate/#{u.uid}"

    assert_response :redirect
    follow_redirect!
    assert_equal flash[:error], 'Only moderators can unmoderate other users.'
    assert_equal u.drupal_user.status, 5
  end

  test 'moderated users can not log in' do
    u = users(:unmoderated_user)
    u.drupal_user.moderate

    post '/user_sessions', user_session: {
      username: u.username,
      password: 'secretive'
    }

    assert_response :redirect
    follow_redirect!
    assert_equal I18n.t('user_sessions_controller.user_has_been_moderated', username: u.username), flash[:error]
  end
end
