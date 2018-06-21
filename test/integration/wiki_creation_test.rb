require 'test_helper'

class WikiCreationTest < ActionDispatch::IntegrationTest
  test 'create new wiki page' do
    post '/user_sessions', params: { user_session: { username: users(:bob).username, password: 'secretive' } }

    title = 'New wiki page title'
    body  = 'This is the body of the new wiki page'

    post '/wiki/create', params: { title: title, body: body }

    follow_redirect!

    assert_equal "/wiki/#{title.parameterize}", path
    assert_equal flash[:notice], 'Wiki page created.'
    assert_select 'h1', title
  end

  test 'create new wiki page without body' do
    post '/user_sessions', params: { user_session: { username: users(:bob).username, password: 'secretive' } }

    title = 'New wiki page title'
    body = nil

    post '/wiki/create', params: { title: title, body: body }

    # Check we get the corresponding error

    node = Node.where(title: title).first

    assert_nil node
    assert_equal '/wiki/create', path
    flash.now[:notice] = "This is the new rich editor. For the legacy editor, <a href='/wiki/new?legacy=true' class='legacy-button'>click here</a>."
    flash[:error] = "Please enter both body and title"
    # Now fill the body, and check it succeeds

    body = 'This is the body of the new wiki page'

    post '/wiki/create', params: { title: title, body: body }

    follow_redirect!

    assert_equal "/wiki/#{title.parameterize}", path
    assert_equal flash[:notice], 'Wiki page created.'
    assert_select 'h1', title
  end

  test 'updating wiki' do
    post '/user_sessions', params: { user_session: { username: users(:bob).username, password: 'secretive' } }
    wiki = nodes(:organizers)
    title = wiki.title
    newtitle = 'New Title'

    post "/wiki/update/#{wiki.id}", params: { uid: users(:bob).id, title: newtitle, body: 'Editing about Page' }

    follow_redirect!

    assert_equal "/wiki/#{title.parameterize}", path
    assert_equal flash[:notice], 'Edits saved.'
  end
end
