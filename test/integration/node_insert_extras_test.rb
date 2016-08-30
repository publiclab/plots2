require 'test_helper'

class NodeInsertExtrasTest < ActionDispatch::IntegrationTest

  test "note with inline tagged notes table via insert_extras() helper" do
    post '/user_sessions', user_session: {
      username: rusers(:jeff).username,
      password: 'secret'
    }

    title = "One more post about balloon mapping"

    post '/notes/create', 
         title: title,
         body:  "This is a fascinating post about a balloon mapping event. \n[notes:test]",
         tags:  "test"

    follow_redirect!
    get DrupalNode.last.path
    
    assert_select "h1", title
    assert_select "table.insert-extras"
  end

  test "note with inline [activities:foo]" do
    post '/user_sessions', user_session: {
      username: rusers(:jeff).username,
      password: 'secret'
    }

    title = "Testing activity grids"

    post '/notes/create', 
         title: title,
         body:  "This is another fascinating post about a balloon mapping event. \n\n[activities:test]",
         tags:  "test"

    follow_redirect!
    get DrupalNode.last.path
    
    assert_select "h1", title
    assert_select "table.activity-grid"
  end

  test "note with inline [upgrades:foo]" do
    post '/user_sessions', user_session: {
      username: rusers(:jeff).username,
      password: 'secret'
    }

    title = "Testing upgrade grids"

    post '/notes/create', 
         title: title,
         body:  "This is another fascinating post about a balloon mapping event. \n\n[upgrades:test]",
         tags:  "test"

    follow_redirect!
    get DrupalNode.last.path
    
    assert_select "h1", title
    assert_select "table.upgrades-grid"
  end

end
