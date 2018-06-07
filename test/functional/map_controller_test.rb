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
end
