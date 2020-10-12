require 'test_helper'

class MapControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get show' do
    map = nodes(:map)
    get :show, params: { name: map.title.parameterize, date: map.created_at.strftime('%m-%d-%Y').slice(0, 19) }

    assert_response :success
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

  test 'should update without duplicating lat/lon tags' do
    UserSession.create(users(:admin))
    map = nodes(:map)
    map.add_tag('lat:1', users(:admin))
    map.add_tag('lon:2', users(:admin))

    put :update, params: { id: map.id, title: 'A map page with a slightly different map', lat: 0.112358, lon: 13.2134, map: {authorship: 'me'} }

    assert_response :success
    updated_map = Node.find map.id
    assert_equal 'A map page with a slightly different map', updated_map.title
    assert_equal [['0.112358'], ['13.2134']], [updated_map.power_tags('lat'), updated_map.power_tags('lon')]
  end
end
