require 'test_helper'

class RevisionSpamTest < ActionDispatch::IntegrationTest
  test 'mark a wiki revision as spam' do
    post '/user_sessions', params: { user_session: { username: users(:admin).username, password: 'secretive' }  } 
      
    revision = revisions(:about_rev_2)

    assert revision.parent.revisions.length > 1

    get '/moderate/revision/spam/' + revision.vid.to_s

    follow_redirect!

    get '/dashboard'
    assert_response :success

    get '/home'
    assert_response :success
  end

  test 'disallow marking a wiki revision as spam when its the only revision' do
    post '/user_sessions', params: { user_session: { username: users(:admin).username, password: 'secretive' } }
      
    revision = revisions(:wiki_page)

    assert_equal 1, revision.parent.revisions.length

    get '/moderate/revision/spam/' + revision.vid.to_s

    follow_redirect!

    assert_equal "You can't delete the last remaining revision of a page; try deleting the wiki page itself (if you're an admin) or contacting moderators@publiclab.org for assistance.", flash[:warning]
    # assert_select ".alert.alert-warning" ,:text => "× You can't delete the last remaining revision of a page; try deleting the wiki page itself (if you're an admin) or contacting moderators@publiclab.org for assistance."

    get '/dashboard'
    assert_response :success

    get '/home'
    assert_response :success
  end
end
