# def new
# def create
# def update
# def edit
# def list
# def likes
# def rss
# def reset
# def comments
# def photo

require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test "new user page" do
    get :new
    assert_response :success
  end

  test "list users" do
    get :list
    assert_response :success
    assert_not_nil :users
  end

  test "list users while logged in" do
    UserSession.create(rusers(:bob))
    get :list
    assert_response :success
    assert_not_nil :users
  end

  test "list users while logged in as admin" do
    UserSession.create(rusers(:admin))
    get :list
    assert_response :success
    assert_not_nil :users
  end

  test "list users by moderator role" do
    UserSession.create(rusers(:bob))
    get :list, id: 'moderator'
    assert_response :success
    assert_not_nil :users
  end

  test "list users by admin role" do
    UserSession.create(rusers(:bob))
    get :list, id: 'admin'
    assert_response :success
    assert_not_nil :users
  end

  test "should not get spam profile" do
    get :profile, id: User.find(3).username  #spam user
    assert_response 302
  end

  test "should get profile" do
    get :profile, id: DrupalUsers.where(status: 1).last.name
    assert_response :success
  end

#  def test_create_invalid
#    User.any_instance.stubs(:valid?).returns(false)
#    post :create
#    assert_template 'new'
#  end

#  def test_create_valid
#    User.any_instance.stubs(:valid?).returns(true)
#    post :create
#    assert_redirected_to root_url
#  end

#  def test_edit
#    user =  FactoryGirl.create(:user)
#    get :edit, :id => user.id
#    assert_template 'edit'
#  end

#  def test_update_invalid
#    User.any_instance.stubs(:valid?).returns(false)
#    put :update, :id => FactoryGirl.create(:user).id
#    assert_template 'edit'
#  end

#  def test_update_valid
#    User.any_instance.stubs(:valid?).returns(true)
#    put :update, :id => User.first
#    assert_redirected_to root_url
#  end

end
