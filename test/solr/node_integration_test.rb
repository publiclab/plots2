require 'test_helper'

class NodeUpdateTest < ActionDispatch::IntegrationTest

  test 'edit note after creating a new note' do

    post '/user_sessions', user_session: {
      username: users(:bob).username,
      password: 'secretive'
    }

    title = 'My second post about balloon mapping'

    post '/notes/create',
         title: title,
         body: 'This is a fascinating post about a balloon mapping event.',
         tags: 'balloon-mapping,event'

    follow_redirect!
    assert_equal '/notes/' + users(:bob).username + '/' +
                 Time.now.strftime('%m-%d-%Y') + '/' + title.parameterize, path

    get '/dashboard'

    assert_response :success

  end
end
