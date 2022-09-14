require 'test_helper'

class MapControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
  end

  test 'renders map for user who has a location' do
    UserSession.create(users(:jeff))

    get :map

    assert_response :success
    assert_equal [59, 15, 10], [assigns(:lat), assigns(:lon), assigns(:zoom)]
  end

  test 'renders map for user who does not have a location' do
    UserSession.create(users(:moderator))
    
    get :map

    assert_response :success
    assert_equal [0, 0, 10], [assigns(:lat), assigns(:lon), assigns(:zoom)]
  end

  test 'renders wiki map that has location' do
    node = nodes(:place)
    get :wiki, params: { id: node.slug }

    assert_response :success
    assert_equal [41.87, -87.64, 13], [assigns(:lat), assigns(:lon), assigns(:zoom)]
  end

  test 'redirects wiki map that does not have location' do
    node = nodes(:organizers)
    get :wiki, params: { id: node.slug }

    assert_redirected_to(controller: "map", action: "map")
  end

  test 'redirects wiki map when wiki does not exist' do
    get :wiki, params: { id: "nil" }

    assert_redirected_to(controller: "map", action: "map")
  end
end
