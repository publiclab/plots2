require 'test_helper'

class MapControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
    # make some map test data:
    #assert_not_nil @maps
    #assert_not_nil @nodes
  end

end
