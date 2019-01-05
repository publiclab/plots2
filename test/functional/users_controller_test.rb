require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper
  def setup
    activate_authlogic

    Geocoder.configure(lookup: :test)

    Geocoder::Lookup::Test.set_default_stub(
      [
        {
          'latitude' => 40.7143528,
          'longitude'    => -74.0059731,
          'address'      => 'New York, NY, USA',
          'state'        => 'New York',
          'state_code'   => 'NY',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ]
    )
  end

  test 'new user page' do
    get :new
    assert_response :success
  end

  test 'list users' do
    get :list
    assert_response :success
    assert_not_nil :users
  end

  test 'list users while logged in' do
    UserSession.create(users(:bob))
    get :list
    assert_response :success
    assert_not_nil :users
  end

  test 'list users while logged in as admin' do
    UserSession.create(users(:admin))
    get :list
    assert_response :success
    assert_not_nil :users
  end

  test 'list users by moderator role' do
    UserSession.create(users(:bob))
    get :list, params: { id: 'moderator' }
    assert_response :success
    assert_not_nil :users
  end

  test 'list users by admin role' do
    UserSession.create(users(:bob))
    get :list, params: { id: 'admin' }
    assert_response :success
    assert_not_nil :users
  end

  test 'should not get spam profile' do
    get :profile, params: { id: User.find(3).username }
    assert_response 302
  end

  test 'should get profile' do
    get :profile, params: { id: User.where(status: 1).first.name }
    assert_response :success
  end

  test 'generate user reset key' do
    user = users(:jeff)
    assert_nil user.reset_key

    get :reset, params: { email: user.email }

    assert_not_nil User.find(user.id).reset_key

    email = ActionMailer::Base.deliveries.last
    assert_equal 'Reset your password', email.subject
    assert_equal [user.email], email.to
  end

  test 'use user reset key to change password' do
    user = users(:jeff)
    crypted_password = user.crypted_password
    key = user.generate_reset_key
    user.save({})

    user_attributes = user.attributes
    user_attributes[:password] = 'newpassword'
    user_attributes[:password_confirmation] = 'newpassword'

    get :reset, params: { key: key, user: user_attributes }

    assert_response :redirect
    assert_redirected_to '/dashboard'

    saved_user = User.find(user.id)
    assert_nil saved_user.reset_key
    assert_not_equal crypted_password, saved_user.crypted_password
    assert_equal 'Your password was successfully changed.', flash[:notice]
  end

  test 'confirm user reset key not visible on profile to non-admins' do
    user = users(:jeff)
    assert_nil user.reset_key
    user.generate_reset_key
    user.save({})
    assert_not_nil User.find(user.id).reset_key

    get :profile, params: { id: user.username }

    selector = css_select 'a.user-reset-key'
    assert_equal selector.size, 0
  end


  test 'confirm user reset key visible to admins on profile' do
    activate_authlogic
    UserSession.create(users(:admin))
    user = users(:jeff)
    user.generate_reset_key
    user.save({})
    assert_not_nil User.find(user.id).reset_key
    get :profile, params: { uid: user.username }
  end

  test 'should choose I18n for users controller' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      get :change_locale, params: { locale: lang.to_s }

      @controller = old_controller
    end
  end

  test 'should list notes and questions in user profile' do
    user = users(:jeff)
    get :profile, params: { id: user.username }
    assert_not_nil assigns(:notes)
    assert_not_nil assigns(:questions)
    assert_not_nil assigns(:answered_questions)
    selector = css_select '#asked .note-question'
    assert_equal selector.size, 2
    selector = css_select '#answered .note-answer'
    assert_equal selector.size, 1
  end

  test 'should get comments' do
    user = users(:jeff)
    get :comments, params: { id: user.id }
    assert_response :success
    assert_not_nil assigns(:comments)
    assert_template partial: 'comments/_comments'
  end

  test 'creating new account' do
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
    assert_difference 'User.count', 1 do
      post :create, params: {
        user: {
          username: 'eleven',
          password: 'demagorgon',
          password_confirmation: 'demagorgon',
          email: 'upside@down.today',
          bio: 'From Hawkins'
        },
        spamaway: {
          statement1: I18n.t('spamaway.human.statement1'),
          statement2: I18n.t('spamaway.human.statement2'),
          statement3: I18n.t('spamaway.human.statement3'),
          statement4: I18n.t('spamaway.human.statement4')
        }
      }
    end
    end
    assert_response :redirect
    # a success here would mean sent back to form with errors
    assert_redirected_to '/dashboard'
    assert_equal 'From Hawkins', User.last.bio
    assert_equal 'upside@down.today', User.last.email

    assert !ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ["notifications@#{request_host}"], email.from
    assert_equal [User.last.email], email.to
    assert_equal "Welcome to Public Lab", email.subject
  end

  test 'updating profile' do
    user = users(:bob)
    UserSession.create(user)
    post :update, params: { user: { bio: 'Hello, there!' } }
    assert_response :redirect
    assert_equal User.find(user.id).bio, 'Hello, there!'
  end

  test 'should redirect edit when not logged in' do
    user = users(:bob)
    get :edit, params: { id: user.name }
    assert_not flash.empty?
    assert_redirected_to '/login'
  end

  test 'should redirect update when not logged in' do
    user = users(:bob)
    post :update, params: { user: { bio: 'Hello, there!' } }
    assert_not flash.empty?
    assert_redirected_to '/login'
  end

  test 'should redirect edit when logged in as another user' do
    user = users(:bob)
    UserSession.create(user)
    new_user = users(:newcomer)
    get :edit, params: { id: new_user.name }
    assert_not flash.empty?
    assert_redirected_to '/profile/' + new_user.name
  end

  test 'rejecting malformated email while updating profile' do
    user = users(:bob)
    email = users(:bob).email
    UserSession.create(user)
    post :update, params: { user: { email: 'not an address' } }
    assert_response :success
    assert_equal user.email, email
  end

  test 'rss feed when username is valid' do
    user = users(:jeff)
    get :rss, params: { author: user.name, format: 'rss' }
    assert_response :success
    assert_equal 'application/xml', @response.content_type
  end

  test 'rss feed when username is not valid' do
    get :rss, params: { author: 'some hacker' }
    assert_response :redirect
    assert_equal I18n.t('users_controller.no_user_found'), flash[:error]
  end

  test "digest emails" do
    user = users(:bob)
    UserSession.create(user)
    post :test_digest_email
    assert_redirected_to '/'
  end

  test '/p/:username (shortlink) redirects to /profile/:id' do
    user = users(:bob)
    username = user.username
    get :shortlink, params: { username: user.username }
    assert_redirected_to "/profile/#{username}"
  end

  test 'invalid username raises proper error' do
    invalid_username = ''
    assert_raises(ActiveRecord::RecordNotFound) do
      get :shortlink, params: { username: invalid_username }
    end
  end

  test 'changing user settings' do
    UserSession.create(users(:bob))
    post :save_settings, params: {
      "notify-comment-direct:false": "on",
      "notify-likes-direct:false": "on",
      "notify-comment-indirect:false": "on",
      "digest:weekly": "on"
    }
    assert_response :success
    assert_not_nil UserTag.where(uid: users(:bob).id, value: 'digest:weekly').last
    assert_equal [], UserTag.where(uid: users(:bob).id, value: "notify-comment-direct:false").last
    assert_equal [], UserTag.where(uid: users(:bob).id, value: "notify-likes-direct:false").last
    assert_equal [], UserTag.where(uid: users(:bob).id, value: "notify-comment-indirect:false").last
    assert_equal [], UserTag.where(uid: users(:bob).id, value: 'digest:digest')
  end
end
