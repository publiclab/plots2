# def show
# def liked? params[:id]
# def create
# def delete
# def set_liking(value)

require 'test_helper'

class LikeControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  def teardown
  end

  test "show like" do
    note = DrupalNode.where(type: 'note', status: 1).first
    get :show, id: note.id
    assert_response :success
  end

  test "create like" do
    UserSession.create(User.find 2)
    current_user = User.find 2
    note = DrupalNode.where(type: 'note', status: 1).first
    cached_likes = note.cached_likes

    get :create, id: note.id
    assert_response :success

    note = DrupalNode.find note.id
    assert_equal @response.body, "1"
    assert_equal note.likers.length, note.cached_likes
    assert_equal cached_likes + 1, note.cached_likes
  end

  test "delete like" do
    UserSession.create(User.find 2)
    current_user = User.find 2
    note = DrupalNode.where(type: 'note', status: 1).first

    get :create, id: note.id # ensure it's liked first

    note = DrupalNode.find note.id
    cached_likes = note.cached_likes
    get :delete, id: note.id
    assert_response :success

    note = DrupalNode.find note.id
    assert_equal @response.body, "-1"
    assert_equal note.likers.length, note.cached_likes
    assert_equal cached_likes - 1, note.cached_likes
  end

end
