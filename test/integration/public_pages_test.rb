require 'test_helper'

class PublicPagesTest < ActionDispatch::IntegrationTest

  def setup
    activate_authlogic
  end

#  test "browse dashboard" do
#    @user_session = UserSession.create(rusers(:bob))
#    get "/dashboard"
#    assert_response :success
#    @user_session.destroy
#  end

  test "browse front page" do
    get "/"
    assert_response :success
  end

  test "browse /maps" do
    get "/maps"
    assert_response :success
  end

  test "view notes for an author" do
    get "/notes/author/" + rusers(:bob).username
    assert_response :success
  end

  test "browse /research" do
    get "/research"
    assert_response :success
  end

  test "browse /login" do
    get "/login"
    assert_response :success
  end

  test "browse /blog" do
    get "/blog"
    assert_response :success
  end

  test "browse /profile/*" do
    get "/profile/" + rusers(:bob).username
    assert_response :success
  end

  test "browse /wiki/foo" do
    node = node(:about)
    get node.path
    assert_response :success
  end

  test "browse /tag/*" do
    get "/tag/test"
    assert_response :success
  end

  test "browse /search/*" do
    get "/search/foo"
    assert_response :success
  end

end

