require 'test_helper'

class UserTagsControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
  end

  test 'should create a new tags' do
    UserSession.create(rusers(:bob))
    assert_difference 'UserTag.count' do
      post :create, id: rusers(:bob).id, name: 'environment'
    end
    assert_equal 'environment tag created successfully', flash[:notice]
    assert_redirected_to info_path
  end

  test 'should create a new tags via xhr' do
    UserSession.create(rusers(:bob))
    xhr :post, :create, id: rusers(:bob).id, name: 'environment'
    assert_response :success
    assert_equal [['environment', UserTag.find_by_value('environment').id]], JSON.parse(response.body)['saved']
  end

  test 'should delete existing tag' do
    UserSession.create(rusers(:bob))
    user_tag = user_tags(:one)
    post :delete, id: user_tag.id
    assert_equal 'Tag deleted.', flash[:notice]
    assert_redirected_to info_path
  end

  test 'cannot delete non-existent tag' do
    UserSession.create(rusers(:bob))
    post :delete, id: 9999
    assert_equal "Tag doesn't exist.", flash[:error]
    assert_redirected_to info_path
  end

  test 'should not create duplicate tag' do
    UserSession.create(rusers(:bob))
    post :create, id: rusers(:bob).id, name: 'environment'
    # duplicate tag
    post :create, id: rusers(:bob).id, name: 'environment'
    assert_equal 'Error: tag already exists.', assigns['output']['errors'][0]
    assert_redirected_to info_path
  end

  test 'should not allow empty tag name' do
    UserSession.create(rusers(:bob))
    post :create, id: rusers(:bob).id, value: ''
    assert_equal 'Error: value cannot be empty', assigns['output']['errors'][0]
    assert_redirected_to info_path
  end

  test 'admin should delete existing tag of normal user' do
    UserSession.create(rusers(:bob))
    post :create, id: rusers(:bob).id, name: 'role:organizer'
    user_tag = UserTag.where(uid: rusers(:bob).id).last
    user_tags_count = UserTag.where(uid: rusers(:bob).id).count
    # Delete above tag
    UserSession.create(rusers(:jeff))
    post :delete, id: user_tag.id
    assert_equal user_tags_count - 1, UserTag.where(uid: rusers(:bob).id).count
  end

  test 'admin should create new tags for normal user' do
    UserSession.create(rusers(:jeff))
    user_tags_count = UserTag.where(uid: rusers(:bob).id).count
    post :create, id: rusers(:bob).id, name: 'role:organizer'
    assert_equal user_tags_count + 1, UserTag.where(uid: rusers(:bob).id).count
  end

  test 'Normal user should not create tag for other user' do
    UserSession.create(rusers(:bob))
    post :create, id: rusers(:jeff).id, name: 'role:organizer'
    assert_equal 'Only admin (or) target user can manage tags', assigns['output']['errors'][0]
  end

  test 'Normal user should not delete tag for other user' do
    user_tag = UserTag.where(uid: rusers(:jeff).id).last
    UserSession.create(rusers(:bob))
    post :delete, id: user_tag.id
    assert_equal 'Only admin (or) target user can manage tags', flash[:error]
  end

  test 'should choose I18n for user tags controller' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      get :change_locale, locale: lang.to_s

      @controller = old_controller

      UserSession.create(rusers(:bob))
      post :delete, id: 9999
      assert_equal I18n.t('user_tags_controller.tag_doesnt_exist'), flash[:error]
    end
  end
end
