require 'test_helper'

class LegacyControllerTest < ActionController::TestCase

  test 'report redirect' do
    get :report, params: { id: nodes(:one).slug }
    assert_response :redirect
  end

end
