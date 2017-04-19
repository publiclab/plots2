require 'test_helper'

class WikiCreationTest < ActionDispatch::IntegrationTest
  test 'create new wiki page' do
    post '/user_sessions', user_session: {
      username: rusers(:bob).username,
      password: 'secret'
    }

    title = 'New wiki page title'
    body  = 'This is the body of the new wiki page'

    post '/wiki/create', title: title, body: body

    follow_redirect!

    assert_equal "/wiki/#{title.parameterize}", path
    assert_equal flash[:notice], 'Wiki page created.'
    assert_select 'h1', title
  end

  test 'create new wiki page without body' do
    post '/user_sessions', user_session: {
      username: rusers(:bob).username,
      password: 'secret'
    }

    title = 'New wiki page title'
    body = nil

    post '/wiki/create', title: title, body: body

    # Check we get the corresponding error

    node = Node.where(title: title).first

    assert_equal node, nil
    assert_equal '/wiki/create', path
    assert_select 'h2', '1 error prohibited this drupal node revision from being saved'

    # Now fill the body, and check it succeeds

    body = 'This is the body of the new wiki page'

    post '/wiki/create', title: title, body: body

    follow_redirect!

    assert_equal "/wiki/#{title.parameterize}", path
    assert_equal flash[:notice], 'Wiki page created.'
    assert_select 'h1', title
  end
end
