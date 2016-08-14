require 'test_helper'

class RelationshipsControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  test "create will follow other user with followed_id param" do
    user = rusers(:admin)
    followed_user = rusers(:jeff)
    UserSession.create(user)
    assert_difference 'Relationship.count', 1 do
      post :create, followed_id: followed_user.id
    end
    assert_response :redirect
    assert_redirected_to '/profile/' + followed_user.username
  end

  test "destroy will remove follow relationship" do
    user = rusers(:jeff)
    UserSession.create(user)
    followed_user = rusers(:bob)
    post :create, followed_id: followed_user.id


    assert_difference 'Relationship.count', -1 do
      delete :destroy, id: Relationship.last.id
    end

    assert_response :redirect
    assert_redirected_to '/profile/' + followed_user.username
  end

  test "actions require authorization" do
    followed_user = rusers(:bob)
    post :create, followed_id: followed_user.id

    assert_response :unprocessable_entity

    post :destroy, id: 1
    assert_response :unprocessable_entity
  end
end
