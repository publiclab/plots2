require 'test_helper'

class PublicPagesTest < ActionDispatch::IntegrationTest
  def setup
    activate_authlogic
  end

  #  test "browse dashboard" do
  #    @user_session = UserSession.create(users(:bob))
  #    get "/dashboard"
  #    assert_response :success
  #    @user_session.destroy
  #  end

  test 'browse front page' do
    get '/'
    assert_response :success
  end

  test 'browse /map' do
    get '/map'
    assert_response :success
  end

  test 'redirect nonexistent routes in /____  format to /wiki/____' do
    get '/chicago'
    assert_response :redirect
    assert_redirected_to '/wiki/chicago'
  end

  test 'view notes for an author' do
    get '/notes/author/' + users(:bob).username
    assert_response :success
  end

  test 'browse /research' do
    get '/research'
    assert_response :success
  end

  test 'browse /login' do
    get '/login'
    assert_response :success
  end

  test 'browse /blog' do
    get '/blog'
    assert_response :success
  end

  test 'browse /profile/*' do
    get '/profile/' + users(:bob).username
    assert_response :success
  end

  test 'browse /wiki/foo' do
    get '/wiki/foo' # non-existent
    assert_response :redirect
    assert_redirected_to '/login'
  end

  test 'browse root-level (/about) wiki page' do
    get '/about'
    assert_response :success
  end

  test 'browse /tag/*' do
    get '/tag/test'
    assert_response :success
  end

  test 'browse /search/*' do
    get '/search/foo'
    assert_response :redirect
    assert_redirected_to '/search?q=foo'
  end

  test 'browse /stats' do
    get '/stats'
    assert_response :success
  end

  test 'browse redirected node' do
    get nodes(:redirect).path
    assert_response :redirect
    assert_redirected_to nodes(:blog).path
    get nodes(:blog).path
    assert_select 'h1', nodes(:blog).title
  end

  test 'browse a question' do
    get nodes(:question).path(:question)
    assert_response :success
  end

  test 'assets tests' do
    get '/assets'
    assert_response :success
  end

  test 'browse people page' do
    get '/people'
    assert_response :success
  end

end


