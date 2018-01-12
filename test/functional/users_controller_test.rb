# def new
# def create
# def update
# def edit
# def list
# def likes
# def rss
# def reset
# def comments
# def photo

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
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
    get :list, id: 'moderator'
    assert_response :success
    assert_not_nil :users
  end

  test 'list users by admin role' do
    UserSession.create(users(:bob))
    get :list, id: 'admin'
    assert_response :success
    assert_not_nil :users
  end

  test 'should not get spam profile' do
    get :profile, id: User.find(3).username # spam user
    assert_response 302
  end

  test 'should get profile' do
    get :profile, id: DrupalUser.where(status: 1).first.name
    assert_response :success
  end

  test 'generate user reset key' do
    user = users(:jeff)
    assert_nil user.reset_key

    get :reset, email: user.email

    assert_not_nil User.find(user.id).reset_key

    email = ActionMailer::Base.deliveries.last
    assert_equal '[Public Lab] Reset your password', email.subject
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

    get :reset, key: key,
	        user: user_attributes

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

    get :profile, id: user.username

    assert_select 'a.user-reset-key', false
  end

  test 'confirm user reset key visible to admins on profile' do
    activate_authlogic
    UserSession.create(users(:admin))
    user = users(:jeff)
    user.generate_reset_key
    user.save({})
    assert_not_nil User.find(user.id).reset_key

    get :profile, id: user.username

    assert_select 'a#user-reset-key'
  end

  test 'should choose I18n for users controller' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      get :change_locale, locale: lang.to_s

      @controller = old_controller
    end
  end

  #  test "should display map with success response" do
  #    UserSession.create(users(:jeff))
  #    get :map
  #    assert_response 200
  #  end

  #  test "should display users map based on location" do
  #    UserSession.create(users(:jeff))
  #    get :map, :country => 'United States', tag: "", value: ""
  #    assert_response 200
  #    assert assigns[:users]
  #  end

  #  test "should display user map on tag and value parameter" do
  #    UserSession.create(users(:jeff))
  #    get :map, :tag => 'Skill', :value => 'Developer', country: ''
  #    assert_response 200
  #    assert assigns[:location_tags]
  #    assert assigns[:location_tags].is_a? Hash
  #  end

  #  test "should display flash error for invalid tag" do
  #    UserSession.create(users(:jeff))
  #    get :map, :tag => 'abc', value: '', country: ''
  #    assert_response 200
  #    assert_equal "abc doesn't exitst", flash[:error]
  #  end

  #  def test_create_invalid
  #    User.any_instance.stubs(:valid?).returns(false)
  #    post :create
  #    assert_template 'new'
  #  end

  #  def test_create_valid
  #    User.any_instance.stubs(:valid?).returns(true)
  #    post :create
  #    assert_redirected_to root_url
  #  end

  #  def test_edit
  #    user =  FactoryGirl.create(:user)
  #    get :edit, :id => user.id
  #    assert_template 'edit'
  #  end

  #  def test_update_invalid
  #    User.any_instance.stubs(:valid?).returns(false)
  #    put :update, :id => FactoryGirl.create(:user).id
  #    assert_template 'edit'
  #  end

  #  def test_update_valid
  #    User.any_instance.stubs(:valid?).returns(true)
  #    put :update, :id => User.first
  #    assert_redirected_to root_url
  #  end

  test 'should list notes and questions in user profile' do
    user = drupal_users(:jeff)
    get :profile, id: user.name
    assert_not_nil assigns(:notes)
    assert_not_nil assigns(:questions)
    assert_not_nil assigns(:answered_questions)
    assert_select '#asked .note-question', 2
    assert_select '#answered .note-answer', 1
  end

  test 'should get comments' do
    user = drupal_users(:jeff)
    get :comments, id: user.id
    assert_response :success
    assert_not_nil assigns(:comments)
    assert_template partial: 'comments/_comments'
  end

  # this isn't testing anything?
  test 'profiles for legacy users' do
    user = drupal_users(:legacy_user)
    assert_response :success
  end

  test 'creating new account' do
    assert_difference 'User.count', 1 do
      post :create, { 
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
    assert_response :redirect
    # a success here would mean sent back to form with errors
    assert_redirected_to '/dashboard'
    assert_equal 'From Hawkins', User.last.bio
    assert_equal 'upside@down.today', User.last.email
  end

  test 'updating profile' do
    user = users(:bob)
    UserSession.create(user)
    post :update, { user: { bio: 'Hello, there!' } }
    assert_response :redirect
    assert_equal User.find(user.id).bio, 'Hello, there!'
  end

  test 'rejecting malformated email while updating profile' do
    user = users(:bob)
    email = users(:bob).email
    UserSession.create(user)
    post :update, { user: { email: 'not an address' } }
    assert_response :success
    assert_equal user.email, email
  end
end
