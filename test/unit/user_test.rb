require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "user creation" do

    user = User.new({
      username: 'chris',
      password: 'science',
      password_confirmation: 'science',
      email: 'test@publiclab.org'
    })

    assert user.save({})

    assert user.first_time_poster
    assert_not_nil user.id
    assert_not_nil user.drupal_user
    assert_not_nil user.uid
    assert_not_nil user.email

  end

  test "basic user attributes" do
    user = rusers(:jeff)
    assert_equal user.notes, user.drupal_user.notes
  end

  test "first time user" do
    assert        users(:jeff).notes.length > 0
    assert        !users(:jeff).first_time_poster
    assert_false  users(:bob).notes.length > 0
    assert        users(:bob).first_time_poster
    assert_false  users(:lurker).notes.length > 0
    assert        users(:lurker).first_time_poster
  end

  test "user reset key" do
    user = rusers(:jeff)
    assert_nil user.reset_key

    user.generate_reset_key
    assert_not_nil user.reset_key
  end

  test "should follow and unfollow user" do
    bob = rusers(:bob)
    jeff = rusers(:jeff)
    #assert_not bob.following?(jeff)
    bob.follow(jeff)
    bob.unfollow(jeff)
  end

end
