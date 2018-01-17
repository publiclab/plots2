require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'user creation' do
    user = User.new(username: 'chris',
                    password: 'godzillas',
                    password_confirmation: 'godzillas',
                    email: 'test@publiclab.org')

    assert user.save({})

    assert user.first_time_poster
    assert_not_nil user.id
    assert_not_nil user.drupal_user
    assert_not_nil user.uid
    assert_not_nil user.email
    assert_not_nil user.bio
    assert_not_nil user.token
    assert_not_nil user.path
    assert_not_nil user.title
  end

  test 'basic user attributes' do
    user = users(:jeff)
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

  test 'user mysql native fulltext search' do
    assert User.count > 0
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      users = User.search('really interesting')
      assert_not_nil users
      assert users.length > 0
    end
  end

  test 'user questions' do
    user = users(:jeff)
    assert !user.questions.empty?
  end

  test 'user.notes and first time user' do
    assert        !drupal_users(:jeff).notes.empty?
    assert        !drupal_users(:jeff).first_time_poster
    assert_not  !drupal_users(:bob).notes.empty?
    assert        drupal_users(:bob).first_time_poster
    assert_not  !drupal_users(:lurker).notes.empty?
    assert        drupal_users(:lurker).first_time_poster
  end

  test 'user reset key' do
    user = users(:jeff)
    assert_nil user.reset_key

    user.generate_reset_key
    assert_not_nil user.reset_key
  end

  test 'should follow and unfollow user' do
    bob = users(:bob)
    jeff = users(:jeff)
    assert_not bob.following?(jeff)
    bob.follow(jeff)
    assert bob.following?(jeff)
    assert jeff.followers.include?(bob)
    bob.unfollow(jeff)
    assert_not bob.following?(jeff)
  end

  test "returns sha email for users who doesn't have image" do
    bob = users(:bob)
    assert_equal 'https://www.gravatar.com/avatar/927536542991ac10fe2c546bc386a521', bob.profile_image
  end

  test 'can add a user_tag and use has_tag method' do
    tag = users(:bob).user_tags.new
    tag.value = 'test:test'
    assert tag.save
    assert users(:bob).has_tag('test:test')
    assert !users(:bob).has_tag('test:no')
  end

  test 'returns nodes created in past given period of time' do
    lurker = users(:lurker)
    node2 = users(:lurker).node.find_by_nid(20)
     assert_equal [node2], lurker.content_followed_in_past_period(2.hours.ago)
  end

  test 'returns value of power tag' do
    bob = users(:bob)
    assert_equal bob.get_value_of_power_tag("skill") , "java"
  end

  test 'has power tag' do
    bob = users(:bob)
    assert bob.has_power_tag("skill")
  end

  test 'returns nodes coauthored by user with coauthored_notes method' do
    jeff = users(:jeff)
    bob = users(:bob)
    assert bob.coauthored_notes.empty?

    jeffs_note = nodes(:one)
    jeffs_note.add_tag('with:bob', jeff)

    coauthored_note = bob.coauthored_notes.first

    assert_not_nil coauthored_note
    assert_equal jeffs_note, coauthored_note
  end

  test 'contributor_count' do
    contributor_count = User.contributor_count_for(Time.now-5.years, Time.now+5.days)
    comment = Comment.new(uid: 99,
                          nid: 2,
                          status: 1,
                          comment: 'Note comment',
                          timestamp: Time.now.to_i + 2,
                          thread: '/02'
              )
    assert comment.save
    current_contributor_count = User.contributor_count_for(Time.now-5.years, Time.now+5.days)
    assert_equal current_contributor_count-contributor_count,1
  end

  test 'user with wrong email' do
    user = User.new(username: 'chris',
                    password: 'godzillas',
                    password_confirmation: 'godzillas',
                    email: 'testpubliclab.org')
    assert_not user.save({})
    assert_equal 1, user.errors[:email].count
  end

end
