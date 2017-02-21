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

  test "user questions" do
    user = rusers(:jeff)
    assert user.questions.length > 0
  end

  test "user.notes and first time user" do
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
    assert_false bob.following?(jeff)
    bob.follow(jeff)
    assert bob.following?(jeff)
    assert jeff.followers.include?(bob)
    bob.unfollow(jeff)
    assert_false bob.following?(jeff)
  end

  test "returns sha email for users who doesn't have image" do
    bob = rusers(:bob)
    assert_equal "https://www.gravatar.com/avatar/927536542991ac10fe2c546bc386a521", bob.profile_image
  end

  test "can add a user_tag and use has_tag method" do
    tag = rusers(:bob).user_tags.new
    tag.value = "test:test"
    assert tag.save
    assert rusers(:bob).has_tag("test:test")
    assert !rusers(:bob).has_tag("test:no")
  end

end
