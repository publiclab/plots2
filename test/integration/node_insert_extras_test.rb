require 'test_helper'

class NodeInsertExtrasTest < ActionDispatch::IntegrationTest
  test 'note with inline tagged notes table via insert_extras() helper' do
    post '/user_sessions', user_session: {
      username: users(:jeff).username,
      password: 'secretive'
    }

    title = 'One more post about balloon mapping'

    post '/notes/create',
         title: title,
         body:  "This is a fascinating post about a balloon mapping event. \n\n[notes:test] \n\n[activities:test] \n\n `[notes:shouldnt]` \n\n[upgrades:test]",
         tags:  'test'

    follow_redirect!

    node = Node.last

    node.add_tag('seeks:replications', users(:jeff))
    seeks_reps = NodeTag.last

    # make the "blog" node a replication
    nodes(:blog).add_tag("replication:#{node.id}", users(:jeff))

    get node.path

    assert_select 'h1', title

    assert_not_nil NodeShared.notes_grid('test')
    assert_equal   4, NodeShared.notes_grid('test').length
    assert_equal   [], Node.activities('shouldnt')
    assert_not_nil Node.upgrades('test')

    assert_select 'table.notes-grid-test'
    assert_select 'table.activity-grid-test'
    assert_select 'table.upgrades-grid-test'
    assert_select 'table.notes-grid-shouldnt', false

    # here we test to see that the requested replications are shown on the bottom of the note
    assert_equal 1, node.response_count('replication')
    assert_select "table.notes-grid-replication-#{node.id}"

    seeks_reps.destroy

    # should list blog with just "activity:" tag
    node.add_tag('activity:test', users(:jeff))

    assert node.has_power_tag('activity')

    get node.path

    assert_select 'h1', title
    assert_select 'table.notes-grid-test'
    assert_select 'table.activity-grid-test'
    assert_select 'table.upgrades-grid-test'
    assert_select 'table.notes-grid-shouldnt', false
    assert_select "table.notes-grid-replication-#{node.id}"
  end
end
