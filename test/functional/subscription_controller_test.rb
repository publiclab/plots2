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
    get :multiple_add, params: { type: 'tag', tagnames: 'blog,kites,,balloon,awesome' }
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
    tagnames = 'blog,kites,,balloon,awesome'
    get :multiple_add, params: { type: "tag", tagnames: tagnames, return_to: "/dashboard" }
    assert_redirected_to "/dashboard"
    assert_equal flash[:notice], "You are now following '#{tagnames}'."
  end
    test 'sorting of digest by title' do
    UserSession.create((users(:bob)))
    get :digest, params: { sort: "title"}
    wikis = assigns(:wikis)
    assert_equal(wikis.first.title,"Canon A1200 IR conversion at PLOTS Barnraising at LUMCON")
    assert_equal(wikis.last.title,"Question by a moderated user")
  end  
  
  test 'sorting of digest by likes' do
   UserSession.create((users(:bob)))
   get :digest, params: { sort: "likes"}
   wikis = assigns(:wikis)
   assert_equal(wikis.first.title, "Canon A1200 IR conversion at PLOTS Barnraising at LUMCON")
   assert_equal(wikis.second.title,"How to use a Spectrometer")
  end
  
  test 'sorting of digest by views' do 
    UserSession.create((users(:bob)))
    get :digest, params: {sort: "page_views"}
    wikis = assigns(:wikis)
    assert_equal(wikis.first.title,"Canon A1200 IR conversion at PLOTS Barnraising at LUMCON")
    assert_equal(wikis.second.title,"Question by a moderated user")
  end
  
  test 'sorting of digest by edits' do
    UserSession.create((users(:bob)))
    get :digest, params: {sort: "edits"}
    wikis = assigns(:wikis)
    assert_equal(wikis.first.title,"How to use a Spectrometer")
    assert_equal(wikis.second.title,"Canon A1200 IR conversion at PLOTS Barnraising at LUMCON")
  end
  test 'sorting by last edited' do
    UserSession.create((users(:bob)))
    get :digest, params: {sort: "last_edited"}
    wikis = assigns(:wikis)
    assert_equal(wikis.last.title,"Canon A1200 IR conversion at PLOTS Barnraising at LUMCON")
  end
end
