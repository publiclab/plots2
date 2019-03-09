require 'test_helper'

class RelationshipsControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
  end

  test 'create will follow other user with followed_id param' do
    user = users(:admin)
    followed_user = users(:jeff)
    UserSession.create(user)
    assert_difference 'Relationship.count', 1 do
      post :create, params: { followed_id: followed_user.id }
    end
    assert_not Relationship.where(followed_id: followed_user.id, follower_id: user.id).empty?
  end

  test 'destroy will remove follow relationship' do
    user = users(:jeff)
    UserSession.create(user)
    followed_user = users(:bob)
    post :create, params: { followed_id: followed_user.id }

    assert_difference 'Relationship.count', -1 do
      delete :destroy, params: { id: followed_user.id }
    end
    assert Relationship.where(followed_id: followed_user.id, follower_id: user.id).empty?
  end

  test 'actions require authorization' do
    followed_user = users(:bob)
    post :create, params: { followed_id: followed_user.id }

    assert_response :unprocessable_entity

    post :destroy, params: { id: 1 }
    assert_response :unprocessable_entity
  end
end
