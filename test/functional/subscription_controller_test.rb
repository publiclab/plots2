require 'test_helper'

class SubscriptionControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  test 'user should be able to subscribe to a tag' do
    UserSession.create(users(:bob))
    get :add, params: { type: 'tag', name: 'blog' }
    assert users(:bob).following(:blog)
  end

  test 'user should be notified if adding a tag already subscribed to' do
    UserSession.create(users(:bob))
    get :add, params: { type: 'tag', name: 'subscribed:tag' }
    assert_equal "You are already subscribed to 'subscribed:tag'", flash[:error]
  end

  test 'should redirect to login if user is not logged in and trying to access digest' do
      get :digest

      assert_redirected_to '/login?return_to=/subscriptions/digest'
  end

  test 'should show digest if user logged in' do
    UserSession.create(users(:bob))
    get :digest

    assert_response :success
  end

  test 'should subscribe to multiple tags' do
    UserSession.create(users(:bob))
    assert users(:bob).following(:awesome)
    get :multiple_add, params: { type: 'tag', tagnames: ["blog","kites","","balloon","awesome"]}
    assert_response :redirect
    assert users(:bob).following(:blog)
    assert users(:bob).following(:awesome)
    assert users(:bob).following(:kites)
    assert users(:bob).following(:balloon)
  end

  test 'should not subscribe to multiple tags in case of empty string' do
    UserSession.create(users(:bob))
    assert users(:bob).following(:awesome)
    get :multiple_add, params: { type: 'tag', tagnames: '' }
    assert_response :redirect
    assert_equal "Please enter tags for subscription in the url.", flash[:notice]
  end

  test 'user is not logged in and tries to subscribe multiple tags' do
    get :multiple_add, params: { type: 'tag', tagnames: 'kites,balloon' }
    assert_redirected_to '/login?return_to=/subscribe/multiple/tag/kites,balloon'
    assert_equal "You must be logged in to subscribe for email updates!", flash[:warning]
  end

  test 'user should be able to follow a tag with a xhr request' do
    UserSession.create((users(:bob)))
    get :add, params: { type: 'tag', name: 'blog' }, xhr: true
    assert users(:bob).following(:blog)
  end

  test "should redirect properly when subscribing to multiple tags" do
    UserSession.create((users(:bob)))
    tagnames = ["blog","kites","","balloon","awesome"]
    get :multiple_add, params: { type: "tag", tagnames: tagnames, return_to: "/dashboard" }
    assert_redirected_to "/dashboard"
    assert_equal flash[:notice], "You are now following #{tagnames.join(', ')}."
  end
end
