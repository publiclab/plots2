require 'test_helper'

class TalkControllerTest < ActionController::TestCase
  test "should get show" do
    node1 = node(:about)
    get :show, id: node1.slug
    assert_response :success
  end
end
