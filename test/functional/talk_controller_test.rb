require 'test_helper'

class TalkControllerTest < ActionController::TestCase

  test "should get show for root page" do
    node = node(:about)
    get :show, id: node.slug
    assert_response :success
  end

  test "should get show" do
    node = node(:organizers)
    get :show, id: node.slug
    assert_response :success
  end

end
