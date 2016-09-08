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
         body:  "This is a fascinating post about a balloon mapping event. \n\n[notes:test] \n\n[activities:test] \n\n `[notes:shouldnt]` \n\n[upgrades:test]",
         tags:  "test"

    follow_redirect!

    node = DrupalNode.last
    node.add_tag("seeks:replications", rusers(:jeff))
    node(:blog).add_tag("replication:#{node.id}", rusers(:jeff))

    get node.path
    
    assert_select "h1", title
    assert_select "table.notes-grid-test"
    assert_select "table.activity-grid-test"
    assert_select "table.upgrades-grid-test"
    assert_select "table.notes-grid-shouldnt", false

    assert_select "table.notes-grid-replication-#{node.id}"

  end

end
