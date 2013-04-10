require 'test_helper'

class NotesControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
    @user =  FactoryGirl.create(:user)
    @drupal_user =  FactoryGirl.create(:drupal_users, :name => @user.username, :mail => @user.email)
  end

  def teardown
    @user.destroy
    @drupal_user.destroy
  end

  def test_post_note_no_login
    # kind of weird, to successfully log out, we seem to have to first log in to get the UserSession...
    user_session = UserSession.create @user
    user_session.destroy
    title = "My new post about balloon mapping"
    post :create, :id => @user.id, :title => title, :body => "This is a fascinating post about a balloon mapping event.", :tags => "balloon-mapping,event"#, :main_image => "/images/testimage.jpg"
    assert_redirected_to('/login')
  end

  def test_post_note
    UserSession.new(@user)
    title = "My new post about balloon mapping"
    post :create, :id => @user.id, :title => title, :body => "This is a fascinating post about a balloon mapping event.", :tags => "balloon-mapping,event"#, :main_image => "/images/testimage.jpg"
    assert_redirected_to "/notes/"+@user.username+"/"+Time.now.strftime("%m-%d-%Y")+"/"+title.parameterize
  end

  def test_post_note_error_no_title
    post :create, :id => @user.id, :body => "This is a fascinating post about a balloon mapping event.", :tags => "balloon-mapping,event"
    assert_template "editor/post"
    assert_select ".alert"
  end

  #def test_cannot_delete_post_if_not_yours

  #end

end
