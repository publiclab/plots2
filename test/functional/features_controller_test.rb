# def index
# def embed
# def new
# def edit
# def create
# def update

require 'test_helper'

class FeaturesControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  test "cannot see /features if not logged in" do
    get :index

    assert_response :redirect
  end

  test "any user can see /features" do
    UserSession.create(rusers(:bob))

    get :index

    assert_response :success
  end

  test "should not get new feature form if not admin" do
    UserSession.create(rusers(:bob))

    get :new

    assert_response :redirect
  end

  test "should get new feature form" do
    UserSession.create(rusers(:admin))

    get :new

    assert_template :new
    assert_response :success
  end

  test "should get features if admin" do
    UserSession.create(rusers(:admin))

    get :index

    assert_template :index
    assert_response :success
    assert_not_nil :features
  end

  test "should not post new feature if not admin" do
    UserSession.create(rusers(:bob))

    assert_difference 'Node.count', 0 do
     
      get :create,
          title: "new-feature",
          body: "A new feature to <a href=''>display</a>"

    end

    assert_equal  "Only admins may edit features.", flash[:warning]
    assert_redirected_to "/features?_=" + Time.now.to_i.to_s
  end

  test "should post new feature" do
    UserSession.create(rusers(:admin))

#    assert_difference 'Node.where(type: "feature").count', 1 do

      get :create,
          title: "new-feature",
          body: "A new feature to <a href=''>display</a>"

#    end

    assert_equal  "Feature saved.", flash[:notice]
    assert_redirected_to "/features?_=" + Time.now.to_i.to_s
  end

  test "should update feature" do
    UserSession.create(rusers(:admin))

    node1 = node(:feature)
    assert_difference 'DrupalNodeRevision.count' do

      get :update,
          id: node1.id,
          body: "A new feature to <a href=''>display</a> with additions"

    end

    assert_equal  "A new feature to <a href=''>display</a> with additions", Node.find(node1.id).latest.body
    assert_equal  "Edits saved and cache cleared.", flash[:notice]
    assert_redirected_to "/features?_=" + Time.now.to_i.to_s
  end

end
