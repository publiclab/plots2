require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'user creation' do
    user = User.new(username: 'chris',
                    password: 'science',
                    password_confirmation: 'science',
                    email: 'test@publiclab.org')

    assert user.save({})

    assert user.first_time_poster
    assert_not_nil user.id
    assert_not_nil user.drupal_user
    assert_not_nil user.uid
    assert_not_nil user.email
    assert_not_nil user.bio
    assert_not_nil user.token
  end

  test 'basic user attributes' do
    user = rusers(:jeff)
    assert_equal user.notes, user.drupal_user.notes
    assert_not_nil user.tags
    assert_not_nil user.drupal_user.tags
    assert_equal user.tags, user.drupal_user.tags
    assert_not_nil user.user_tags
    assert_not_nil user.drupal_user.user_tags
    assert_equal user.user_tags, user.drupal_user.user_tags
    assert_not_nil user.tagnames
    assert_not_nil user.drupal_user.tagnames
    assert_equal user.tagnames, user.drupal_user.tagnames
  end

  test 'user questions' do
    user = rusers(:jeff)
    assert !user.questions.empty?
  end

  test 'user.notes and first time user' do
    assert        !users(:jeff).notes.empty?
    assert        !users(:jeff).first_time_poster
    assert_false  !users(:bob).notes.empty?
    assert        users(:bob).first_time_poster
    assert_false  !users(:lurker).notes.empty?
    assert        users(:lurker).first_time_poster
  end

  test 'user reset key' do
    user = rusers(:jeff)
    assert_nil user.reset_key

    user.generate_reset_key
    assert_not_nil user.reset_key
  end

  test 'should follow and unfollow user' do
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
    assert_equal 'https://www.gravatar.com/avatar/927536542991ac10fe2c546bc386a521', bob.profile_image
  end

  test 'can add a user_tag and use has_tag method' do
    tag = rusers(:bob).user_tags.new
    tag.value = 'test:test'
    assert tag.save
    assert rusers(:bob).has_tag('test:test')
    assert !rusers(:bob).has_tag('test:no')
  end

  test 'returns nodes created in past given period of time' do
    lurker = rusers(:lurker)
    node2 = rusers(:lurker).node.find_by_nid(20)
     assert_equal [node2], lurker.content_followed_in_past_period(2.hours.ago)
  end

  test 'returns value of power tag' do
    bob = rusers(:bob)
    assert_equal bob.get_value_of_power_tag("question") , "spectrometer"
  end

  test 'has power tag' do
    bob = rusers(:bob)
    assert bob.has_power_tag("question")
  end

end
