require 'test_helper'

class NodeInsertExtrasTest < ActionDispatch::IntegrationTest
  test 'note with inline tagged notes table via insert_extras() helper' do
    post '/user_sessions', user_session: {
      username: rusers(:jeff).username,
      password: 'secret'
    }

    title = 'One more post about balloon mapping'

    post '/notes/create',
         title: title,
         body:  "This is a fascinating post about a balloon mapping event. \n\n[notes:test] \n\n[activities:test] \n\n `[notes:shouldnt]` \n\n[upgrades:test]",
         tags:  'test'

    follow_redirect!

    node = Node.last

    node.add_tag('seeks:replications', rusers(:jeff))
    seeks_reps = NodeTag.last

    # make the "blog" node a replication
    node(:blog).add_tag("replication:#{node.id}", rusers(:jeff))

    get node.path

    assert_select 'h1', title

    assert_not_nil NodeShared.notes_grid('test')
    assert_equal   [], Node.activities('shouldnt')
    assert_not_nil Node.upgrades('test')

    assert_select 'table.notes-grid-test'
    assert_select 'table.activity-grid-test'
    assert_select 'table.activity-grid-test tr.title'
    assert_select 'table.upgrades-grid-test'
    assert_select 'table.notes-grid-shouldnt', false

    assert_select "table.notes-grid-replication-#{node.id}"

    seeks_reps.destroy

    # should list blog with just "activity:" tag
    node.add_tag('activity:test', rusers(:jeff))

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
