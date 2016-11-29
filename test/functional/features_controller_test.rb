# def index
# def embed
# def new
# def edit
# def create
# def update

require 'test_helper'

class FeaturesControllerTest < ActionController::TestCase

  test "should not get features if not admin" do
    UserSession.create(rusers(:bob))
    get :index
    assert_response :redirect
  end

  test "should not get new feature form if not admin" do
    UserSession.create(rusers(:bob))

    get :new

    assert_response :redirect
  end

  test "should get new feature form" do
    UserSession.create(rusers(:admin))

    get :new

    assert_response :success
  end

  # fix log in before this can work:

  #test "should get features if admin" do
  #  session[:user_id] = rusers(:jeff).id # log in
  #  get :index
  #  assert_response :success
  #  assert_not_nil :features
  #end

end
