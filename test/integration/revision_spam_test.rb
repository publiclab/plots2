require 'test_helper'

class RevisionSpamTest < ActionDispatch::IntegrationTest
  test 'mark a wiki revision as spam' do
    post '/user_sessions', user_session: {
      username: users(:admin).username,
      password: 'secretive'
    }

    revision = revisions(:about_rev_2)

    get '/moderate/revision/spam/' + revision.vid

    follow_redirect!

    get '/dashboard'
    assert_response :success

    get '/home'
    assert_response :success
  end

  test 'disallow marking a wiki revision as spam when its the only revision' do
    post '/user_sessions', user_session: {
      username: users(:admin).username,
      password: 'secretive'
    }

    revision = revisions(:wiki_page)

    get '/moderate/revision/spam/' + revision.vid

    follow_redirect!

    get '/dashboard'
    assert_response :success

    get '/home'
    assert_response :success
  end
end
