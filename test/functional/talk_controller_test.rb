require 'test_helper'

class TalkControllerTest < ActionController::TestCase
  test "should get show" do
  	node = node(:about)
    get :show, id: node.slug[0,50]
    assert_response :success
  end
end
