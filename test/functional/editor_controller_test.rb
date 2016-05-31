require 'test_helper'

class EditorControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  test "should not get post form if not logged in" do
    get :post
    assert_redirected_to '/login?return_to=/post'
  end

  test "should get post form" do
    UserSession.create(rusers(:bob))
    get :post
    assert_response :success
    assert_select "h3", "Share your work"
    assert_select "span.moderation-notice", false
  end

  test "newcomer should get post form" do
    UserSession.create(rusers(:newcomer))
    get :post
    assert_response :success
    assert_select "h3", "Share your work"
    assert_select "p.moderation-notice", "Hi! Just letting you know ahead of time that everyone's first posts to this website are moderated due to issues we've had with spam. Thanks for your patience!"
  end

end
