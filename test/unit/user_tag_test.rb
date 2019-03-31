require 'test_helper'

class UserTagTest < ActiveSupport::TestCase
  test 'should create UserTag' do
    user = users(:jeff)
    user_tag = UserTag.new(uid: user.id,
                           value: 'skill:Entrepreneur')

    assert user_tag.save
    assert_not_nil user_tag.id
    assert_not_nil user_tag.uid
    assert_not_nil user_tag.value
    assert_not_nil user_tag.name # for compatibility with regular node_tags, but we should deprecate this

    # downcases:
    assert_equal 'skill:entrepreneur', user_tag.value

    assert_not_nil user.user_tags
  end

  test 'should not contains special characters in value' do
    user = users(:jeff)
    invalid_values = ['"', '""', "'", '$']
    invalid_values.each do |value|
      invalid_user_tag = UserTag.new(uid: user.id,
                                     value: "skill:#{value}")
      invalid_user_tag.save
      assert_equal ['Value can only include letters, numbers, and dashes'], invalid_user_tag.errors.full_messages
    end
  end

  test 'Create a usertag from google auth' do
    user = users(:jeff)
    auth = { "provider" => "google_oauth2", "uid" => "123456789"}
    uid = user.id
    identity1 = UserTag.create_with_omniauth(auth, uid)
    assert_not_nil identity1
    identity2 = UserTag.find_with_omniauth(auth)
    assert_not_nil identity1
    assert_equal(identity1, identity2)
  end

  test 'Create a usertag from twitter auth' do
    user = users(:jeff)
    auth = { "provider" => "twitter", "uid" => "123456789"}
    uid = user.id
    identity1 = UserTag.create_with_omniauth(auth, uid)
    assert_not_nil identity1
    identity2 = UserTag.find_with_omniauth(auth)
    assert_not_nil identity1
    assert_equal(identity1, identity2)
  end

  test 'Create a usertag from twitter auth and also store hash function' do
    twitter_user_tag = user_tags(:twitter3)
    auth = twitter_user_tag.data
    uid = twitter_user_tag.uid
    identity1 = UserTag.create_with_omniauth(auth, uid)
    assert_equal identity1.uid, twitter_user_tag.uid
    assert_equal identity1.data["uid"], auth["uid"]
    assert_equal identity1.data["info"]["nickname"], "itsmenamangupta"
  end

  test 'Create a usertag from facebook auth' do
    user = users(:jeff)
    auth = { "provider" => "facebook", "uid" => "123456789"}
    uid = user.id
    identity1 = UserTag.create_with_omniauth(auth, uid)
    assert_not_nil identity1
    identity2 = UserTag.find_with_omniauth(auth)
    assert_not_nil identity1
    assert_equal(identity1, identity2)
  end

  test 'Create a usertag from github auth' do
    user = users(:jeff)
    auth = { "provider" => "github", "uid" => "123456789"}
    uid = user.id
    identity1 = UserTag.create_with_omniauth(auth, uid)
    assert_not_nil identity1
    identity2 = UserTag.find_with_omniauth(auth)
    assert_not_nil identity1
    assert_equal(identity1, identity2)
  end

  test 'Search a usertag from google auth which does not exist' do
    user = users(:jeff)
    auth = { "provider" => "google_oauth2", "uid" => "12345678"}
    uid = user.id
    identity = UserTag.find_with_omniauth(auth)
    assert_nil identity
  end

  test 'Search a usertag from twitter auth which does not exist' do
    user = users(:jeff)
    auth = { "provider" => "twitter", "uid" => "12345678"}
    uid = user.id
    identity = UserTag.find_with_omniauth(auth)
    assert_nil identity
  end

  test 'Search a usertag from github auth which does not exist' do
    user = users(:jeff)
    auth = { "provider" => "github", "uid" => "12345678"}
    uid = user.id
    identity = UserTag.find_with_omniauth(auth)
    assert_nil identity
  end

  test 'Search a usertag from facebook auth which does not exist' do
    user = users(:jeff)
    auth = { "provider" => "facebook", "uid" => "12345678"}
    uid = user.id
    identity = UserTag.find_with_omniauth(auth)
    assert_nil identity
  end

  test 'Search a usertag from google auth which does exist' do
    user = users(:jeff)
    auth = { "provider" => "google_oauth2", "uid" => "987654321"}
    uid = user.id
    identity = UserTag.find_with_omniauth(auth)
    assert_not_nil identity
  end

  test 'Search a usertag from twitter auth which does exist' do
    user = users(:jeff)
    auth = { "provider" => "twitter", "uid" => "987654321"}
    uid = user.id
    identity = UserTag.find_with_omniauth(auth)
    assert_not_nil identity
  end

  test 'Search a usertag from github auth which does exist' do
    user = users(:jeff)
    auth = { "provider" => "github", "uid" => "987654321"}
    uid = user.id
    identity = UserTag.find_with_omniauth(auth)
    assert_not_nil identity
  end

  test 'Search a usertag from facebook auth which does exist' do
    user = users(:jeff)
    auth = { "provider" => "facebook", "uid" => "987654321"}
    uid = user.id
    identity = UserTag.find_with_omniauth(auth)
    assert_not_nil identity
  end

  test 'exists, remove_if_exists, create_if_absent' do
    uid = 1
    value = 'test'
    assert_not UserTag.exists?(uid, value)
    UserTag.create(uid: uid, value: value)
    assert UserTag.exists?(uid, value)
    UserTag.create_if_absent(uid, value)
    assert_equal 1, UserTag.where(uid: uid, value: value).length
    UserTag.remove_if_exists(uid, value)
    assert_not UserTag.exists?(1, 'test')
    UserTag.create_if_absent(uid, value)
    assert UserTag.exists?(uid, value)
  end

end
