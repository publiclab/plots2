require 'test_helper'

class SubscriptionControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  test 'should redirect to login if user is not logged in and trying to access digest' do
      get :digest

      assert_redirected_to '/login'
  end

  test 'should show digest if user logged in' do
    UserSession.create(users(:bob))
    get :digest

    assert_response :success
  end

end