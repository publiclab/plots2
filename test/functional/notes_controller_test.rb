# def index
# def tools
# def places
# def shortlink
# def raw
# def show
# def create
# def edit
# def update
# def delete
# def author
# def author_topic
# def liked
# def popular
# def rss
# def liked_rss
# def rsvp

require 'test_helper'

class NotesControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
    @user =  FactoryGirl.create(:user)
  end

  def teardown
    @user.destroy
  end

  test "redirect note short url" do
    note = DrupalNode.where(type: 'note', status: 1).last
    get :shortlink, id: note.id
    assert_redirected_to note.path
  end

  test "show note by id" do
    note = DrupalNode.where(type: 'note', status: 1).last
    assert_not_nil note.id
    get :show, id: note.id
    assert_response :success
  end

  test "show note" do
    note = DrupalNode.where(type: 'note', status: 1).last
    get :show, author: note.author.name, date: Time.at(note.created).strftime("%m-%d-%Y"), id: note.title.parameterize
    assert_response :success
  end

  test "don't show note by spam author" do
    note = DrupalNode.find_by_nid(3) # spam fixture
    get :show, author: note.author.name, date: Time.at(note.created).strftime("%m-%d-%Y"), id: note.title.parameterize
    assert_redirected_to '/'
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil :notes
  end

  test "should get raw note markup" do
    id = DrupalNode.where(type: 'note', status: 1).last.id
    get :raw, id: id
    assert_response :success
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

  test "post note no login" do
    # kind of weird, to successfully log out, we seem to have to first log in to get the UserSession...
    user_session = UserSession.create @user
    user_session.destroy
    title = "My new post about balloon mapping"
    post :create, :id => @user.id, :title => title, :body => "This is a fascinating post about a balloon mapping event.", :tags => "balloon-mapping,event"#, :main_image => "/images/testimage.jpg"
    assert_redirected_to('/login?return_to=/notes/create')
  end

  test "post note" do
    UserSession.create(@user)
    title = "My new post about balloon mapping"
    post :create, :title => title, :body => "This is a fascinating post about a balloon mapping event.", :tags => "balloon-mapping,event"#, :main_image => "/images/testimage.jpg"
    assert_redirected_to "/notes/"+@user.username+"/"+Time.now.strftime("%m-%d-%Y")+"/"+title.parameterize
  end

  test "post_note_error_no_title" do
    post :create, :body => "This is a fascinating post about a balloon mapping event.", :tags => "balloon-mapping,event"
    assert_template "editor/post"
    assert_select ".alert"
  end

  #def test_cannot_delete_post_if_not_yours

  #end

  test "edit note" do
    UserSession.create(@user)
    title = "My second post about balloon mapping"
    post :create, :title => title, :body => "This is a fascinating post about a balloon mapping event.", :tags => "balloon-mapping,event"#, :main_image => "/images/testimage.jpg"
    assert_redirected_to "/notes/"+@user.username+"/"+Time.now.strftime("%m-%d-%Y")+"/"+title.parameterize

    # add a tag, and change the title and body
    newtitle = title + " which I amended"
    post :update, :id => DrupalNode.where(title: title).first.id, :title => newtitle, :body => "This is a fascinating post about a balloon mapping event. <span id='teststring'>added content</span>", :tags => "balloon-mapping,event,meetup"
    assert_redirected_to "/notes/"+@user.username+"/"+Time.now.strftime("%m-%d-%Y")+"/"+title.parameterize

    get :show, {:author => @user.username, :date => Time.now.strftime("%m-%d-%Y"), :id => title.parameterize}
    assert_equal flash[:notice], "Edits saved."
    assert_select "h1", newtitle
    # assert_select "span#teststring", "added content" # this test does not work!! very frustrating. 
    # assert_select ".label", "meetup" # test for tag addition too, later
  end

  test "should load iframe url in comments" do
    comment = DrupalComment.new({
      nid: node(:one).nid,
      uid: rusers(:bob).id,
      thread: "01/"
    })
    comment.comment = '<iframe src="http://mapknitter.org/embed/sattelite-imagery" style="border:0;"></iframe>'
    comment.save
    node = node(:one).path.split("/")
    get :show, id: node[4], author: node[2], date: node[3]
    assert_tag :tag => 'iframe', attributes: {src: 'http://mapknitter.org/embed/sattelite-imagery'}
  end

end
