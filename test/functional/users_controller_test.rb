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

  def setup
    activate_authlogic
  end

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

  test "generate user reset key" do
    user = rusers(:jeff)
    assert_nil user.reset_key

    get :reset, email: user.email

    assert_not_nil User.find(user.id).reset_key

    email = ActionMailer::Base.deliveries.last
    assert_equal "[Public Lab] Reset your password", email.subject
    assert_equal [user.email], email.to
  end

  test "use user reset key to change password" do
    user = rusers(:jeff)
    crypted_password = user.crypted_password
    key = user.generate_reset_key
    user.save({})

    user_attributes = user.attributes
    user_attributes[:password] = 'newpass'

    get :reset, key: key, user: user_attributes 

    saved_user = User.find(user.id)

    assert_nil saved_user.reset_key
    assert_equal "Your password was successfully changed.", flash[:notice]
    assert_not_equal crypted_password, saved_user.crypted_password

  end

  test "confirm user reset key not visible on profile to non-admins" do
    user = rusers(:jeff)
    assert_nil user.reset_key
    user.generate_reset_key
    user.save({})
    assert_not_nil User.find(user.id).reset_key

    get :profile, id: user.username

    assert_select 'a.user-reset-key', false
  end

  test "confirm user reset key visible to admins on profile" do
    activate_authlogic
    UserSession.create(rusers(:admin))
    user = rusers(:jeff)
    user.generate_reset_key
    user.save({})
    assert_not_nil User.find(user.id).reset_key

    get :profile, id: user.username

    assert_select 'a#user-reset-key'

  end

  test "should update true value of location privacy attribute" do
    UserSession.create(rusers(:jeff))
    user = rusers(:jeff)
    post :privacy, location_privacy: true, :id => user.username

    assert_response 302
    assert user.location_privacy
    assert_equal "Your preference has been saved", flash[:notice]
  end

  test "should update false value location privacy attribute" do
    UserSession.create(rusers(:jeff))
    user = rusers(:jeff)
    post :privacy, location_privacy: false, :id => user.username

    assert_response 302
    assert user.location_privacy
    assert_equal "Your preference has been saved", flash[:notice]
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
