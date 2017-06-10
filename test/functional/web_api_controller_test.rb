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
end
