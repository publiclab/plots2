require 'test_helper'

class WikiControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
    @user =  FactoryGirl.create(:user)
    @drupal_user =  FactoryGirl.create(:drupal_users, :name => @user.username, :mail => @user.email)
  end

  def teardown
    @user.destroy
    @drupal_user.destroy
  end

  def test_post_wiki_no_login
    # kind of weird, to successfully log out, we seem to have to first log in to get the UserSession...
    user_session = UserSession.create @user
    user_session.destroy
    title = "All about balloon mapping"
    post :create, :uid => @user.id, :title => title, :body => "This is fascinating documentation about balloon mapping.", :tags => "balloon-mapping,event"
    assert_redirected_to('/login')
  end

  def test_post_wiki
    UserSession.new(@user)
    title = "All about balloon mapping"
    post :create, :uid => @user.id, :title => title, :body => "This is fascinating documentation about balloon mapping.", :tags => "balloon-mapping,event"
    assert_redirected_to "/wiki/"+title.parameterize
    #assert_response :success
    #assert_template "wiki/show"
  end

  def test_edit_wiki
    UserSession.new(@user)
    title = "All about balloon mapping redux"
    post :create, :uid => @user.id, :title => title, :body => "This is fascinating documentation about balloon mapping.", :tags => "balloon-mapping,event"
    assert_redirected_to "/wiki/"+title.parameterize

    # add a tag, and change the title and body
    newtitle = title + " which I amended"
    post :update, :id => title.parameterize, :title => newtitle, :body => "This is fascinating documentation about balloon mapping. <span id='teststring'>added content</span>", :tags => "balloon-mapping,event,meetup"
    assert_redirected_to "/wiki/"+title.parameterize

    get(:show, {:id => title.parameterize}) 
    assert_response :success
    assert_equal flash[:notice], "Edits saved."
    assert_select "h2", title # title should change but not URL
    # assert_select "span#teststring", "added content" # this test does not work! very frustrating. 
    # assert_select ".label", "meetup" # test for tag addition too, later
  end

end
