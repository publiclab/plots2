require 'test_helper'

class NodeUpdateTest < ActionDispatch::IntegrationTest

  test "edit note after creating a new note" do
    post '/user_sessions', user_session: {
      username: rusers(:bob).username,
      password: 'secret'
    }

    title = "My second post about balloon mapping"

    post '/notes/create', 
         title: title, 
         body: "This is a fascinating post about a balloon mapping event.", 
         tags: "balloon-mapping,event"

    follow_redirect!
    assert_equal "/notes/" + rusers(:bob).username + "/" +
                 Time.now.strftime("%m-%d-%Y") + "/" + title.parameterize, path

    node = DrupalNode.where(title: title).first

    # approve the first-timer's note:
    node.publish

    # add a tag, and change the title and body
    newtitle = title + " which I amended"

    post '/notes/update/' + node.id.to_s,
         title: newtitle, 
         body: "This is a fascinating post about a balloon mapping event. <span id='teststring'>added content</span>", 
         tags: "balloon-mapping,event,meetup"
    follow_redirect!
    # path does not get updated
    assert_equal "/notes/" + rusers(:bob).username + "/" +
                 Time.now.strftime("%m-%d-%Y") + "/" + title.parameterize, path

    assert_equal flash[:notice], "Edits saved."

    # visiting note with original path
    get "/notes/" + rusers(:bob).username + "/" + 
        Time.now.strftime("%m-%d-%Y") + "/" + title.parameterize
    assert_response :success
    assert_select "h1", newtitle
    assert_select "span#teststring", "added content" 
    # assert_select ".label", "meetup" # test for tag addition too, later
  end

end
