# def index
# def embed
# def new
# def edit
# def create
# def update

require 'test_helper'

class FeaturesControllerTest < ActionController::TestCase
  def setup
    Timecop.freeze # account for timestamp change
    activate_authlogic
  end

  def teardown
    Timecop.return
  end

  test 'cannot see /features if not logged in' do
    get :index

    assert_response :redirect
  end

  test 'any user can see /features' do
    UserSession.create(users(:bob))

    get :index

    assert_response :success
  end

  test 'should not get new feature form if not admin' do
    UserSession.create(users(:bob))

    get :new

    assert_response :redirect
  end

  test 'should get new feature form' do
    UserSession.create(users(:admin))

    get :new

    assert_template :new
    assert_response :success
  end

  test 'should get features if admin' do
    UserSession.create(users(:admin))

    get :index

    assert_template :index
    assert_response :success
    assert_not_nil :features
  end

  test 'should not post new feature if not admin' do
    UserSession.create(users(:bob))

    assert_difference 'Node.count', 0 do
      get :create,
          title: 'new-feature',
          body: "A new feature to <a href=''>display</a>"
    end

    assert_equal 'Only admins may edit features.', flash[:warning]
    assert_redirected_to '/features?_=' + Time.now.to_i.to_s
  end

  test 'should post new feature' do
    UserSession.create(users(:admin))

    #    assert_difference 'Node.where(type: "feature").count', 1 do

    get :create,
        title: 'new-feature',
        body: "A new feature to <a href=''>display</a>"

    #    end

    assert_equal 'Feature saved.', flash[:notice]
    assert_redirected_to '/features?_=' + Time.now.to_i.to_s
  end

  test 'should update feature' do
    UserSession.create(users(:admin))

    node = nodes(:feature)
    assert_difference 'Revision.count' do
      get :update,
          id: node.id,
          body: "A new feature to <a href=''>display</a> with additions"
    end

    assert_equal  "A new feature to <a href=''>display</a> with additions", Node.find(node.id).latest.body
    assert_equal  'Edits saved and cache cleared.', flash[:notice]
    assert_redirected_to '/features?_=' + Time.now.to_i.to_s
  end
end
