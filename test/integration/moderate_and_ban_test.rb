require 'test_helper'

class ModerateAndBanTest < ActionDispatch::IntegrationTest

  test "users are logged out and alerted when banned, and notes are not accessible" do
    u = rusers(:bob)
    post '/user_sessions', user_session: {
      username: u.username,
      password: 'secret' 
    }

    get '/post' # dashboard is actually world-readable, but /post is not

    assert_response :success

    u.drupal_user.ban

    get '/post' # dashboard is actually world-readable, but /post is not

    follow_redirect!
    # in application_controller.rb; normal logged out message to deter spammers:
    assert_equal "You must be logged in to access this page", flash[:warning]

    get u.notes.first.path

    assert_response :redirect
    follow_redirect!
    # in application_controller.rb:
    assert_equal "The author of that note has been banned.", flash[:error]

    get node(:question3).path # a Q by bob

    assert_response :redirect
    follow_redirect!
    # in application_controller.rb:
    assert_equal "The author of that note has been banned.", flash[:error]

    get "/profile/#{u.username}"

    assert_response :redirect
    follow_redirect!
    # in application_controller.rb:
    assert_equal I18n.t('users_controller.user_has_been_banned'), flash[:error]

    u.drupal_user.unban

    get u.notes.first.path

    assert_response :success

  end

  test "users are logged out and alerted when moderated, and notes are not accessible" do
    u = rusers(:bob)
    post '/user_sessions', user_session: {
      username: u.username,
      password: 'secret' 
    }

    get '/post' # dashboard is actually world-readable, but /post is not

    assert_response :success
    u.drupal_user.moderate

    get '/post' # dashboard is actually world-readable, but /post is not

    follow_redirect!
    # in application_controller.rb:
    assert_equal "The user 'Bob' has been placed in moderation; please see <a href='https://publiclab.org/wiki/moderators'>our moderation policy</a> and contact <a href='mailto:moderators@publiclab.org'>moderators@publiclab.org</a> if you believe this is in error.", flash[:warning]

    get u.notes.first.path

    assert_response :success
    assert_equal "The user 'Bob' has been placed <a href='https://publiclab.org/wiki/moderators'>in moderation</a> and will not be able to respond to comments.", flash[:warning]

    get node(:question3).path # a Q by bob

    assert_response :success
    # in application_controller.rb:
    assert_equal "The user 'Bob' has been placed <a href='https://publiclab.org/wiki/moderators'>in moderation</a> and will not be able to respond to comments.", flash[:warning]

    u.drupal_user.unmoderate

    get u.notes.first.path

    assert_response :success
    assert_nil flash[:warning]

  end

  #test "users are logged out and alerted when banned" do
  #end

end
