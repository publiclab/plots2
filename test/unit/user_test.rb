require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'user creation' do
    user = User.new(username: 'chris',
                    password: 'godzillas',
                    password_confirmation: 'godzillas',
                    bio: 'my name is chris.',
                    email: 'test@publiclab.org')

    assert user.save

    assert user.first_time_poster
    assert_not_nil user.id
    assert_not_nil user.uid
    assert_not_nil user.email
    assert_not_nil user.bio
    assert_not_nil user.token
    assert_not_nil user.path
    assert_not_nil user.title
  end

  test 'basic user attributes' do
    user = users(:jeff)
    assert_equal user.notes, user.notes
    assert_not_nil user.tags
    assert_not_nil user.tags
    assert_equal user.tags, user.tags
    assert_not_nil user.user_tags
    assert_not_nil user.user_tags
    assert_equal user.user_tags, user.user_tags
    assert_not_nil user.tagnames
    assert_not_nil user.tagnames
    assert_equal user.tagnames, user.tagnames
    assert_not_nil user.recent_locations
    assert_not_nil user.latest_location
  end

  test 'user creation with create_with_omniauth' do
    auth = {
      'info' => {
        'email' => 'bobafett@email.com' # there should not already be a username like this
      },
      'provider' => 'github'
    }
    user = User.create_with_omniauth(auth)
    assert_equal 1, user.status
    assert_equal 'bobafett', user.username
    assert_equal 2, user.password_checker
  end

  test 'user with duplicate username creation with create_with_omniauth' do
    auth = {
      'info' => {
        'email' => 'bob@email.com' # there should already be a bob user
      },
      'provider' => 'facebook'
    }
    user = User.create_with_omniauth(auth)
    assert_equal 1, user.status
    assert_not_equal 'bob', user.username
    assert_equal 1, user.password_checker
  end

  test 'user mysql native fulltext search' do
    assert User.count > 0
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      users = User.search('jeff')
      assert_not_nil users
      assert users.length > 0
    end
  end

  test 'user questions' do
    user = users(:jeff)
    assert !user.questions.empty?
  end

  test 'user.notes and first time user' do
    assert        !users(:jeff).notes.empty?
    assert        !users(:jeff).first_time_poster
    assert_not  !users(:bob).notes.empty?
    assert        users(:bob).first_time_poster
    assert_not  !users(:lurker).notes.empty?
    assert        users(:lurker).first_time_poster
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

  test 'returns notes created in given period of time' do
    bob = users(:bob)
    node_count = 4
    nodes_fix = [1 ,8 ,9 , 15]
    count_return = bob.content_followed_in_period(2.hours.ago, Time.now).count
    nodes_time = bob.content_followed_in_period(2.hours.ago, Time.now).pluck(:nid)
    assert_equal node_count, count_return
    assert_equal nodes_fix, nodes_time.sort
  end

  test 'returns wikis updated in given period of time' do
    bob = users(:bob)
    node_count = 2
    nodes_fix = [2, 5]
    count_return = bob.content_followed_in_period(2.hours.ago, Time.now, 'page').count
    nodes_time = bob.content_followed_in_period(2.hours.ago, Time.now, 'page').pluck(:nid)
    assert_equal node_count, count_return
    assert_equal nodes_fix, nodes_time.sort
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
    assert_not user.save
    assert_not_nil user.errors[:email]
  end

  test 'user status changes when banned or unbanned' do
    user = users(:bob)
    assert_equal 1, user.status
    user.ban
    assert_equal 0, user.status
    user.unban
    assert_equal 1, user.status
  end

  test 'user status changes when user is moderated or unmoderated' do
    user = users(:bob)
    assert_equal 1, user.status
    user.moderate
    assert_equal 5, user.status
    user.unmoderate
    assert_equal 1, user.status
  end

  test 'user roles' do
    admin = users(:admin)
    assert admin.admin?
    assert admin.can_moderate?

    moderator = users(:moderator)
    assert moderator.moderator?
    assert moderator.can_moderate?

    basic_user = users(:newcomer)
    assert_not basic_user.admin?
    assert_not basic_user.moderator?
    assert_not basic_user.can_moderate?
  end

  test 'user email validation' do
    user = User.new(username: 'zen',
                    password: 'nez',
                    password_confirmation: 'nez',
                    email: 'abc@.com')
    assert_not user.save
  end

  test 'email validation' do
    user = User.new(username: 'himanshu',
                    password: 'bhallu',
                    password_confirmation: 'bhallu',
                    email: '@xyz.com')
    assert_not user.save
  end

  test 'send_digest_email' do
    assert users(:bob).send_digest_email
  end

  test 'create a user with omniauth if email prefix does not exist in db' do
    auth = {"uid" => "98746858591", "info" => { "email" => "bansal.sidharth2990@gmail.com"}}
    sidharth = User.create_with_omniauth(auth)
    assert_not_nil sidharth
    assert_equal sidharth.email, "bansal.sidharth2990@gmail.com"
    #as username "bansal_sidharth2990" does not exist in the db, user with username = "bansal_sidharth2990" will be created
    assert_equal sidharth.username, "bansal_sidharth2990"
  end

  test 'create a user with omniauth if email prefix does exist in db' do
    auth = {"uid" => "98740858591", "info" => { "email" => "jeff@gmail.com"},"provider"=>"facebook"}
    jeffrey = User.create_with_omniauth(auth)
    assert_not_nil jeffrey
    assert_equal jeffrey.email, "jeff@gmail.com"
    assert_equal jeffrey.password_checker, 1
    #as the username as "jeff" exists, hence username = "jeff" + 2 digit alphanumeric code will be created
    assert_not_equal jeffrey.username, "jeff"
  end

  test 'generate token and validate token correctness test' do
    user_obj = User.first
    generated_token = user_obj.generate_token
    assert_equal User.validate_token(generated_token), user_obj.id
  end

  test 'do not verify users email if the token is not generated for him' do
    all_users = User.where("id<?", 3)
    generated_token = all_users[0].generate_token
    if all_users.length > 1
      assert_not_equal User.validate_token(generated_token), all_users[1].id
    end
  end

  test 'raise exception upon invalid token' do
    user_obj = User.first
    generated_token = user_obj.generate_token
    generated_token = generated_token[2,generated_token.length]
    assert_equal User.validate_token(generated_token), 0
  end

  test 'do not validate email if token has expired' do
    assert_equal User.validate_token(User.encrypt({:id => 1, :timestamp => Time.now - (24*60*60+1)})), 0
  end

  test 'check default value of is_verified remains false' do
    user_new_obj = User.new
    assert_equal user_new_obj.is_verified, false
  end

  test 'make sure that values in that column gets updated' do
    user_obj = User.first
    user_obj.update_column(:is_verified,true)
    assert_equal user_obj.is_verified, true
    user_obj.update_column(:is_verified,false)
    assert_equal user_obj.is_verified, false
  end

  test 'username should not be updated' do
    user = users(:bob)
    user.username = 'newval'
    user.save!
    user.reload
    assert_equal user.username, 'Bob'
    assert_raises ActiveRecord::ActiveRecordError do
      user.update_attribute(:username, 'new_user')
    end
  end

  test 'for_subscriptions' do
    user = users(:bob)
    assert_equal  user.subscriptions(:tag).size, 3
  end
end
