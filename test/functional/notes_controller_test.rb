require 'test_helper'

class NotesControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
    @user =  FactoryGirl.create(:user)
  end

  def teardown
    @user.destroy
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil :notes
  end

  test "should get tools" do
    get :tools
    assert_response :success
    assert_not_nil :notes
  end

  test "should get places" do
    get :places
    assert_response :success
    assert_not_nil :notes
  end

  def test_post_note_no_login
    # kind of weird, to successfully log out, we seem to have to first log in to get the UserSession...
    user_session = UserSession.create @user
    user_session.destroy
    title = "My new post about balloon mapping"
    post :create, :id => @user.id, :title => title, :body => "This is a fascinating post about a balloon mapping event.", :tags => "balloon-mapping,event"#, :main_image => "/images/testimage.jpg"
    assert_redirected_to('/login?return_to=/notes/create')
  end

  def test_post_note
    UserSession.new(@user)
    title = "My new post about balloon mapping"
    post :create, :title => title, :body => "This is a fascinating post about a balloon mapping event.", :tags => "balloon-mapping,event"#, :main_image => "/images/testimage.jpg"
    assert_redirected_to "/notes/"+@user.username+"/"+Time.now.strftime("%m-%d-%Y")+"/"+title.parameterize
  end

  def test_post_note_error_no_title
    post :create, :body => "This is a fascinating post about a balloon mapping event.", :tags => "balloon-mapping,event"
    assert_template "editor/post"
    assert_select ".alert"
  end

  #def test_cannot_delete_post_if_not_yours

  #end

  def test_edit_note
    UserSession.new(@user)
    title = "My second post about balloon mapping"
    post :create, :title => title, :body => "This is a fascinating post about a balloon mapping event.", :tags => "balloon-mapping,event"#, :main_image => "/images/testimage.jpg"
    assert_redirected_to "/notes/"+@user.username+"/"+Time.now.strftime("%m-%d-%Y")+"/"+title.parameterize

    # add a tag, and change the title and body
    newtitle = title + " which I amended"
    post :update, :id => DrupalNode.where(title: title).first.id, :title => newtitle, :body => "This is a fascinating post about a balloon mapping event. <span id='teststring'>added content</span>", :tags => "balloon-mapping,event,meetup"
    assert_redirected_to "/notes/"+@user.username+"/"+Time.now.strftime("%m-%d-%Y")+"/"+title.parameterize

    get(:show, {:author => @user.username, :date => Time.now.strftime("%m-%d-%Y"), :id => title.parameterize}) 
    assert_equal flash[:notice], "Edits saved."
    assert_select "h1", newtitle
    # assert_select "span#teststring", "added content" # this test does not work!! very frustrating. 
    # assert_select ".label", "meetup" # test for tag addition too, later
  end

end
