require 'test_helper'

class LegacyControllerTest < ActionController::TestCase

  test 'report redirect' do
    get :report, id: 'my-very-first-post-to-public-lab'
    assert_response :redirect
  end

end
