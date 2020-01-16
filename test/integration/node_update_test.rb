require 'test_helper'

class NodeUpdateTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  test 'edit note after creating a new note' do
    post '/user_sessions', params: { user_session: { username: users(:bob).username, password: 'secretive' } }

    title = 'My second post about balloon mapping'

    post '/notes/create', params: { title: title, body: 'This is a fascinating post about a balloon mapping event.', tags: 'balloon-mapping,event' }

    follow_redirect!
    assert_equal '/notes/' + users(:bob).username + '/' +
                 Time.now.strftime('%m-%d-%Y') + '/' + title.parameterize, path

    node = Node.where(title: title).first

    # approve the first-timer's note:
    node.publish

    # add a tag, and change the title and body
    newtitle = title + ' which I amended'

    post '/notes/update/' + node.id.to_s,
      params: {
        title: newtitle,
        body: "This is a fascinating post about a balloon mapping event. <span id='teststring'>added content</span>",
        tags: 'balloon-mapping,event,meetup'
      }
         
    follow_redirect!
    # path does not get updated
    assert_equal '/notes/' + users(:bob).username + '/' +
                 Time.now.strftime('%m-%d-%Y') + '/' + title.parameterize, path

    assert_equal flash[:notice], 'Edits saved.'

    # visiting note with original path
    get '/notes/' + users(:bob).username + '/' +
        Time.now.strftime('%m-%d-%Y') + '/' + title.parameterize
    assert_response :success
    assert_select 'h1', newtitle
    assert_select 'span#teststring', 'added content'
    # assert_select ".label", "meetup" # test for tag addition too, later
  end
end
