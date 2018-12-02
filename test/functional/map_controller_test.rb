require 'test_helper'

class MapControllerTest < ActionController::TestCase
  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get show' do
    map = nodes(:map)
    get :show, params: { name: map.title.parameterize, date: map.created_at.strftime('%m-%d-%Y').slice(0, 19) }

    assert_response :success
  end

  test 'should update without duplicating lat/lon tags' do
    activate_authlogic
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
