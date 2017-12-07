require 'test_helper'

class NodeSeriesTagTest < ActionDispatch::IntegrationTest
  test 'add series tag' do
    post '/user_sessions', user_session: {
      username: users(:bob).username,
      password: 'secretive'
    }

    title = 'My second post about balloon mapping'

    post '/notes/create',
         title: title,
         body: 'This is a fascinating post about a balloon mapping event.',
         tags: 'series:balloons'

    follow_redirect!
    assert_equal '/notes/' + users(:bob).username + '/' +
                 Time.now.strftime('%m-%d-%Y') + '/' + title.parameterize, path

    node = Node.where(title: title).first
    assert_equal true, node.has_power_tag('series')
    assert_equal 'balloons', node.power_tag('series')

    # approve the first-timer's note:
    node.publish

    # visiting note with original path
    get '/notes/' + users(:bob).username + '/' +
        Time.now.strftime('%m-%d-%Y') + '/' + title.parameterize
    assert_select '.alert', 'This is part of a series on  balloons.'
  end
end
