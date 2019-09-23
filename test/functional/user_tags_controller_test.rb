require 'test_helper'

class UserTagsControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
  end

  test 'should create a new tags' do
    UserSession.create(users(:bob))
    assert_difference 'UserTag.count' do
      post :create, params: { id: users(:bob).id, name: 'environment' }
    end
    assert_equal 'environment tag created successfully', flash[:notice]
    assert_redirected_to "/profile/#{users(:bob).username}"
  end

  test 'should create a new tags via xhr' do
    UserSession.create(users(:bob))
    post :create, params: { id: users(:bob).id, name: 'environment' }, xhr: true
    assert_response :success
    assert_equal [['environment', UserTag.where(value:'environment').first.id]], JSON.parse(response.body)['saved']
  end

  test 'should create two new tags from "one,two"' do
    UserSession.create(users(:bob))
    assert_difference 'UserTag.count', 2 do
      post :create, params: { name: 'one,two', nid: nodes(:one).nid, id: users(:bob).id }, xhr: true
    end
    assert_response :success
    assert_equal [['one', UserTag.where(value: 'one').first.id], ['two', UserTag.where(value: 'two').first.id]], JSON.parse(response.body)['saved']
  end

  test 'should delete existing tag' do
    UserSession.create(users(:bob))
    user_tag = user_tags(:one)
    delete :delete , params: { id: users(:bob).id , name: user_tag.name }
    assert_equal 'Tag deleted.', flash[:notice]
    assert_redirected_to info_path
  end

  test 'should render a text/plain when a tag is deleted through post request xhr' do
    UserSession.create(users(:bob))
    user_tag = user_tags(:two)
    delete :delete , params: { id: users(:bob).id , name: user_tag.name }, xhr: true
    assert_equal user_tag.tid, JSON.parse(@response.body)['tid']
  end

  test 'cannot delete non-existent tag' do
    UserSession.create(users(:bob))
    delete :delete, params: { id: users(:bob).id , name: "temp tag" }
    assert_equal "Tag doesn't exist.", flash[:error]
    assert_redirected_to info_path
  end

  test 'should not create duplicate tag' do
    UserSession.create(users(:bob))
    post :create, params: { id: users(:bob).id, name: 'environment' }
    # duplicate tag
    post :create, params: {id: users(:bob).id, name: 'environment' }
    assert_equal 'Error: tag already exists.', assigns[:output][:errors][0]
    assert_redirected_to "/profile/#{users(:bob).username}"
  end

  test 'should not allow empty tag name' do
    UserSession.create(users(:bob))
    post :create, params: { id: users(:bob).id, value: '' }
    assert_equal 'Error: value cannot be empty', assigns[:output][:errors][0]
    assert_redirected_to "/profile/#{users(:bob).username}"
  end

  test 'admin should delete existing tag of normal user' do
    UserSession.create(users(:bob))
    post :create, params: { id: users(:bob).id, name: 'role:organizer' }
    user_tag = UserTag.where(uid: users(:bob).id).last
    user_tags_count = UserTag.where(uid: users(:bob).id).count
    # Delete above tag
    UserSession.create(users(:jeff))
    delete :delete, params: { id: users(:bob).id , name: user_tag.name }
    assert_equal user_tags_count - 1, UserTag.where(uid: users(:bob).id).count
  end

  test 'admin should create new tags for normal user' do
    UserSession.create(users(:jeff))
    user_tags_count = UserTag.where(uid: users(:bob).id).count
    post :create, params: { id: users(:bob).id, name: 'role:organizer' }
    assert_equal user_tags_count + 1, UserTag.where(uid: users(:bob).id).count
  end

  test 'Normal user should not create tag for other user' do
    UserSession.create(users(:bob))
    post :create, params: { id: users(:jeff).id, name: 'role:organizer' }
    assert_equal 'Only admin (or) target user can manage tags', assigns[:output][:errors][0]
  end

  test 'Normal user should not delete tag for other user' do
    user_tag = UserTag.where(uid: users(:jeff).id).last
    UserSession.create(users(:bob))
    delete :delete, params: { id: users(:jeff).id , name: user_tag.name }
    assert_equal 'Only admin (or) target user can manage tags', flash[:error]
  end

  test 'should choose I18n for user tags controller' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      get :change_locale, params: { locale: lang.to_s }

      @controller = old_controller

      UserSession.create(users(:bob))
      delete :delete, params: { id: users(:bob).id , name: "temp tag" }
      assert_equal I18n.t('user_tags_controller.tag_doesnt_exist'), flash[:error]
    end
  end

  test 'user tags index' do
   get :index

   assert :success
   assert assigns['user_tags']
   assert_equal assigns['user_tags'].collect{ |a| a[0] }, assigns['user_tags'].collect{ |a| a[0]}.uniq
   assert_not assigns['user_tags'].include?(0)
   assert_not_nil :user_tags

   get :index, params: {sort: "value"}
   assert_equal assigns['user_tags'].collect{ |a| [a[0], a[1]] }, assigns['user_tags'].sort_by{ |a| [a[0]]}

 end

 test 'user tags search' do
   get :index, params: { search: "skill:rails" }

   assert :success
   assert assigns(:user_tags).length > 0
   assert_template 'user_tags/index'
 end

  test 'should report error if delete tag non existing (xhr req)' do
    UserSession.create(users(:bob))
    delete :delete, xhr: true, params: { id: users(:bob).id , name: "N/A" }
    assert response.body.include? "Tag doesn't exist."
    assert_not JSON.parse(response.body)['status']
  end

end
