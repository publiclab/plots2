require 'test_helper'

class SubscriptionControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  test 'user should be able to subscribe to a tag' do
    UserSession.create(users(:bob))
    get :add, params: { type: 'tag', name: 'blog' }

    assert_response :redirect
    assert users(:bob).following(:blog)
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

  test 'should subscribe to multiple tags' do
    UserSession.create(users(:bob))
    assert users(:bob).following(:awesome)
    get :multiple_add, params: { type: 'tag', names: 'blog,kites,,balloon,awesome' }
    assert_response :redirect
    assert users(:bob).following(:blog)
    assert users(:bob).following(:awesome)
    assert users(:bob).following(:kites)
    assert users(:bob).following(:balloon)
  end
end
