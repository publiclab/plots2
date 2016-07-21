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
    # path gets updated
    assert_equal "/notes/" + rusers(:bob).username + "/" +
                 Time.now.strftime("%m-%d-%Y") + "/" + newtitle.parameterize, path

    assert_equal flash[:notice], "Edits saved."

    # visiting note with new path
    get "/notes/" + rusers(:bob).username + "/" + 
        Time.now.strftime("%m-%d-%Y") + "/" + newtitle.parameterize
    assert_response :success
    assert_select "h1", newtitle
    assert_select "span#teststring", "added content" 
    # assert_select ".label", "meetup" # test for tag addition too, later
  end

  test "should redirect to new note path when visiting with old url" do
    post '/user_sessions', user_session: {
      username: rusers(:jeff).username,
      password: 'secret'
    }
    
    node = node(:one)
    oldtitle = node.title
    newtitle = oldtitle + " which I amended"

    post '/notes/update/' + node.id.to_s,
         title: newtitle, 
         body: "Some test string"

    follow_redirect!
    # path gets updated
    assert_equal "/notes/" + rusers(:jeff).username + "/" +
                 node.created_at.strftime("%m-%d-%Y") + "/" + newtitle.parameterize, path

    assert_equal flash[:notice], "Edits saved."

    # visiting note with old path
    get '/notes/' + rusers(:jeff).username + "/" + 
        node.created_at.strftime("%m-%d-%Y") + "/" + oldtitle.parameterize

    follow_redirect!
    assert_equal '/notes/' + rusers(:jeff).username + "/" +
                 node.created_at.strftime("%m-%d-%Y") + "/" +
                 newtitle.parameterize, path

  end

  test "should redirect to new path for question when visiting with old url" do
    post '/user_sessions', user_session: {
      username: rusers(:jeff).username,
      password: 'secret'
    }
    
    node = node(:question)
    oldtitle = node.title
    newtitle = oldtitle + " which I amended"

    post '/notes/update/' + node.id.to_s,
         title: newtitle, 
         body: "Some test string",
         redirect: "question"

    follow_redirect!
    # path gets updated
    assert_equal "/questions/" + rusers(:jeff).username + "/" +
                 node.created_at.strftime("%m-%d-%Y") + "/" + newtitle.parameterize, path

    assert_equal flash[:notice], "Edits saved."

    # visiting note with old path
    get '/questions/' + rusers(:jeff).username + "/" + 
        node.created_at.strftime("%m-%d-%Y") + "/" + oldtitle.parameterize

    follow_redirect!
    assert_equal '/questions/' + rusers(:jeff).username + "/" +
                 node.created_at.strftime("%m-%d-%Y") + "/" +
                 newtitle.parameterize, path

  end

  test "should redirect to new wiki path when visiting with old url" do
    post '/user_sessions', user_session: {
      username: rusers(:bob).username,
      password: 'secret'
    }
    
    node = node(:about)
    oldtitle = node.title
    newtitle = oldtitle + " page amended"

    post '/wiki/update/' + node.id.to_s,
         title: newtitle, 
         body: "Some test string"

    follow_redirect!
    # path gets updated
    assert_equal "/wiki/" + newtitle.parameterize, path

    assert_equal flash[:notice], "Edits saved."

    # visiting note with old path
    get '/wiki/' + oldtitle.parameterize

    follow_redirect!
    assert_equal '/wiki/' + newtitle.parameterize, path

  end

  test "should take the old url if the title is reverted to the old title" do
    post '/user_sessions', user_session: {
      username: rusers(:bob).username,
      password: 'secret'
    }

    node = node(:about)
    oldtitle = node.title
    newtitle = oldtitle + " page amended"

    post '/wiki/update/' + node.id.to_s,
         title: newtitle, 
         body: "Some test string"

    follow_redirect!
    # path gets updated
    assert_equal "/wiki/" + newtitle.parameterize, path
    assert_equal flash[:notice], "Edits saved."

    # reverting to the old title
    post '/wiki/update/' + node.id.to_s,
         title: oldtitle, 
         body: "Some test string"

    follow_redirect!
    # path gets changed to the old url
    assert_equal "/wiki/" + oldtitle.parameterize, path
    assert_equal flash[:notice], "Edits saved."
  end

  test "should reuse old slugs if a new wiki page is created with an old title of another wiki" do
    post '/user_sessions', user_session: {
      username: rusers(:bob).username,
      password: 'secret'
    }

    node = node(:about)
    oldtitle = node.title
    newtitle = oldtitle + " page amended"

    post '/wiki/update/' + node.id.to_s,
         title: newtitle, 
         body: "Some test string"

    follow_redirect!
    assert_equal "/wiki/" + newtitle.parameterize, path
    assert_equal flash[:notice], "Edits saved."

    # create wiki page with oldtitle
    post '/wiki/create/',
         title: oldtitle,
         body: "Test string"

    follow_redirect!
    assert_equal "/wiki/" + oldtitle.parameterize, path
  end

end
