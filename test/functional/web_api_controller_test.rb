
# Test for WebApiController pages



require 'test_helper'

class WebApiControllerTest < ActionController:: TestCase

  def setup
    activate_authlogic
  end

  test 'web_api should return index.html' do
    get :index
    assert_response :success
  end
<<<<<<< HEAD
end
=======
end
>>>>>>> b5a7285cc30049763de259409059f36e3d6e93b3
