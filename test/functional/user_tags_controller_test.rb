require 'test_helper'

class UserTagsControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
  end

  test 'should create a new tags' do
    UserSession.create(users(:bob))
    assert_difference 'UserTag.count' do
      post :create, id: users(:bob).id, name: 'environment'
    end
    assert_equal 'environment tag created successfully', flash[:notice]
    assert_redirected_to info_path
  end

  test 'should create a new tags via xhr' do
    UserSession.create(users(:bob))
    xhr :post, :create, id: users(:bob).id, name: 'environment'
    assert_response :success
    assert_equal [['environment', UserTag.where(value:'environment').first.id]], JSON.parse(response.body)['saved']
  end

  test 'should create two new tags from "one,two"' do
    UserSession.create(users(:bob))
    assert_difference 'UserTag.count', 2 do
      xhr :post, :create, name: 'one,two', nid: nodes(:one).nid, id: users(:bob).id
    end
    assert_response :success
    assert_equal [['one', UserTag.where(value: 'one').first.id], ['two', UserTag.where(value: 'two').first.id]], JSON.parse(response.body)['saved']
  end

  test 'should delete existing tag' do
    UserSession.create(users(:bob))
    user_tag = user_tags(:one)
    post :delete, id: user_tag.id , name: user_tag.value
    assert_equal 'Tag deleted.', flash[:notice]
    assert_redirected_to info_path
  end

  test 'cannot delete non-existent tag' do
    UserSession.create(users(:bob))
    post :delete, id: 9999 , name: user_tag.value
    assert_equal "Tag doesn't exist.", flash[:error]
    assert_redirected_to info_path
  end

  test 'should not create duplicate tag' do
    UserSession.create(users(:bob))
    post :create, id: users(:bob).id, name: 'environment'
    # duplicate tag
    post :create, id: users(:bob).id, name: 'environment'
    assert_equal 'Error: tag already exists.', assigns[:output][:errors][0]
    assert_redirected_to info_path
  end

  test 'should not allow empty tag name' do
    UserSession.create(users(:bob))
    post :create, id: users(:bob).id, value: ''
    assert_equal 'Error: value cannot be empty', assigns[:output][:errors][0]
    assert_redirected_to info_path
  end

  test 'admin should delete existing tag of normal user' do
    UserSession.create(users(:bob))
    post :create, id: users(:bob).id, name: 'role:organizer'
    user_tag = UserTag.where(uid: users(:bob).id).last
    user_tags_count = UserTag.where(uid: users(:bob).id).count
    # Delete above tag
    UserSession.create(users(:jeff))
    post :delete, id: user_tag.id , name: user_tag.value
    assert_equal user_tags_count - 1, UserTag.where(uid: users(:bob).id).count
  end

  test 'admin should create new tags for normal user' do
    UserSession.create(users(:jeff))
    user_tags_count = UserTag.where(uid: users(:bob).id).count
    post :create, id: users(:bob).id, name: 'role:organizer'
    assert_equal user_tags_count + 1, UserTag.where(uid: users(:bob).id).count
  end

  test 'Normal user should not create tag for other user' do
    UserSession.create(users(:bob))
    post :create, id: users(:jeff).id, name: 'role:organizer'
    assert_equal 'Only admin (or) target user can manage tags', assigns[:output][:errors][0]
  end

  test 'Normal user should not delete tag for other user' do
    user_tag = UserTag.where(uid: users(:jeff).id).last
    UserSession.create(users(:bob))
    post :delete, id: user_tag.id , name: user_tag.value
    assert_equal 'Only admin (or) target user can manage tags', flash[:error]
  end

  test 'should choose I18n for user tags controller' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      get :change_locale, locale: lang.to_s

      @controller = old_controller

      UserSession.create(users(:bob))
      post :delete, id: 9999 , name: user_tag.value
      assert_equal I18n.t('user_tags_controller.tag_doesnt_exist'), flash[:error]
    end
  end
end
