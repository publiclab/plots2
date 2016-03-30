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
  end

end
