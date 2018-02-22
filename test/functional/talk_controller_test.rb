require 'test_helper'

class TalkControllerTest < ActionController::TestCase
  test 'should get show for root page' do
    node = nodes(:about)
    get :show, id: node.slug
    assert_response :success
  end

  test 'should get show' do
    node = nodes(:organizers)
    get :show, id: node.slug
    assert_response :success
  end
end
