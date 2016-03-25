# def subdomain
# def show
# def raw
# def edit
# def new
# def create
# def update
# def delete
# def revert
# def root
# def revisions
# def revision
# def index
# def popular
# def liked

require 'test_helper'

class WikiControllerTest < ActionController::TestCase
  self.use_instantiated_fixtures = true

  def setup
    activate_authlogic
    @user =  FactoryGirl.create(:user)
  end

  def teardown
    @user.destroy
  end

  test "should get wiki index" do
    get :index
    assert_response :success
    assert_not_nil :wikis
  end

  test "should get raw wiki markup" do
    id = DrupalNodeRevision.last.id
    get :raw, id: id
    assert_response :success
  end

  test "should get wiki page" do
    id = DrupalNode.where(type: 'page').last.id
    get :show, id: id
    assert_response :success
  end

  test "post wiki no login" do
    # kind of weird, to successfully log out, we seem to have to first log in to get the UserSession...
    user_session = UserSession.create @user
    user_session.destroy
    title = "All about balloon mapping"
    post :create, :uid => @user.id, :title => title, :body => "This is fascinating documentation about balloon mapping.", :tags => "balloon-mapping,event"
    assert_redirected_to('/login?return_to=/wiki/create')
  end

  test "post wiki" do
    UserSession.new(@user)
    title = "All about balloon mapping"
    post :create, :uid => @user.id, :title => title, :body => "This is fascinating documentation about balloon mapping.", :tags => "balloon-mapping,event"
    assert_redirected_to "/wiki/"+title.parameterize
    #assert_response :success
    #assert_template "wiki/show"
  end

  test "edit wiki" do
    UserSession.new(@user)
    title = "All about balloon mapping redux"
    post :create, :uid => @user.id, :title => title, :body => "This is fascinating documentation about balloon mapping.", :tags => "balloon-mapping,event"
    assert_redirected_to "/wiki/"+title.parameterize

    # add a tag, and change the title and body
    newtitle = title + " which I amended"
    nid = DrupalNodeRevision.find_by_title(title).nid
    post :update, :id => nid, :title => newtitle, :body => "This is fascinating documentation about balloon mapping. <span id='teststring'>added content</span>", :tags => "balloon-mapping,event,meetup"
    assert_redirected_to "/wiki/"+title.parameterize

    get(:show, {:id => title.parameterize}) 
    assert_response :success
    assert_equal flash[:notice], "Edits saved."
    # This is WRONG! It should be newtitle, not title, right?:
    assert_select "h1", newtitle # title should change but not URL
    # assert_select "span#teststring", "added content" # this test does not work! very frustrating. 
    # assert_select ".label", "meetup" # test for tag addition too, later
  end

  test "update wiki uploading new image" do
    UserSession.new(@user)
    node = DrupalNode.where(type: 'page').last
    image = fixture_file_upload 'rails.png'
    post :update, :id => node.nid, :uid => @user.id,
                  :title => "New Title", :body => "Editing about Page", 
                  :image => { :title => "new image",
                              :photo => image 
                   }
    assert_redirected_to node.path
    assert_equal flash[:notice], "Edits saved."
  end

  test "update wiki selecting previous image" do
    UserSession.new(@user)
    node = DrupalNode.where(type: 'page').last
    image = node.images.where(photo_file_name: 'filename-1.jpg').last
    post :update, :id => node.nid, :uid => @user.id,
                  :title => "New Title", :body => "Editing about Page",
                  :image_revision => image.id
    assert_redirected_to node.path
    assert_equal flash[:notice], "Edits saved."
  end

  test "normal user should not delete wiki page" do
    UserSession.new(@user)
    title = "All about balloon mapping"
    post :create, :uid => @user.id, :title => title, :body => "This is fascinating documentation about balloon mapping.", :tags => "balloon-mapping,event"
    assert_redirected_to "/wiki/" + title.parameterize
    nid = DrupalNode.find_by_title(title).nid
    post :delete, :id => nid
    assert_equal flash[:error], "Only admins can delete wiki pages."
    assert_redirected_to "/wiki/" + title.parameterize
  end

  test "admin user should delete wiki page" do
    @user.role = "admin"
    @user.save!
    UserSession.new(@user)
    title = "All about balloon mapping"
    post :create, :uid => @user.id, :title => title, :body => "This is fascinating documentation about balloon mapping.", :tags => "balloon-mapping,event"
    assert_redirected_to "/wiki/" + title.parameterize
    nid = DrupalNode.find_by_title(title).nid
    post :delete, :id => nid
    assert_equal flash[:notice], "Wiki page deleted."
    assert_redirected_to "/dashboard"
  end

  test "should display wiki pages with slug in root" do
    @user.role = "admin"
    @user.save!
    wiki_page = DrupalNode.create!(
      "type" => "page",
      "title" => "About",
      "uid" => @user.id,
      "status" => 1,
      "comment" => 0,
      "cached_likes" => 0
    )

    get :root, id: "invalid"
    assert_template file: 'public/404'
  end

  test "admin should revert wiki page to parent version" do
    @user.role = "admin"
    @user.save!
    UserSession.new(@user)
    title = "All about balloon mapping"
    post :create, :uid => @user.id, :title => title, :body => "This is fascinating documentation about balloon mapping.", :tags => "balloon-mapping,event"
    assert_redirected_to "/wiki/" + title.parameterize

    nid = DrupalNodeRevision.find_by_title(title)
    get :revert, id: nid
    assert_equal flash[:notice], "The wiki page was reverted."
    assert_redirected_to "/wiki/" + title.parameterize
  end

  test "user cannot revert wiki page" do
    UserSession.new(@user)
    title = "All about balloon mapping"
    post :create, :uid => @user.id, :title => title, :body => "This is fascinating documentation about balloon mapping.", :tags => "balloon-mapping,event"
    assert_redirected_to "/wiki/" + title.parameterize

    nid = DrupalNodeRevision.find_by_title(title)
    get :revert, id: nid
    assert_equal flash[:error], "Only moderators and admins can delete wiki pages."
    assert_redirected_to "/wiki/" + title.parameterize
  end

  test "should display revisions" do
    @user.role = "admin"
    @user.save!
    UserSession.new(@user)
    title = "All about balloon mapping"
    post :create, :uid => @user.id, :title => title, :body => "This is fascinating documentation about balloon mapping.", :tags => "balloon-mapping,event"
    assert_redirected_to "/wiki/" + title.parameterize

    #Edit wiki page
    newtitle = title + "Edited page"
    nid = DrupalNodeRevision.find_by_title(title).nid
    post :update, :id => nid, :title => newtitle, :body => "This is fascinating documentation about balloon mapping. <span id='teststring'>added content</span>", :tags => "balloon-mapping,event,meetup"
    assert_redirected_to "/wiki/" + title.parameterize

    get :revisions, id: title.parameterize
    assert_template :revisions
  end

  test "should not error if no node exist" do
    UserSession.new(@user)
    title = "All about balloon mapping"
    post :create, :uid => @user.id, :title => title, :body => "This is fascinating documentation about balloon mapping.", :tags => "balloon-mapping,event"
    assert_redirected_to "/wiki/" + title.parameterize

    get :revisions, id: "Invalid Node"
    assert_template :revisions
    assert_equal flash[:error], "Invalid wiki page. No Revisions exist for this wiki page."
  end

  test "should display individual version" do
    UserSession.new(@user)
    title = "All about balloon mapping"
    post :create, :uid => @user.id, :title => title, :body => "This is fascinating documentation about balloon mapping.", :tags => "balloon-mapping,event"
    assert_redirected_to "/wiki/" + title.parameterize

    vid = DrupalNodeRevision.find_by_title(title).vid
    get :revision, id: title.parameterize, vid: vid
    assert_template "show"
  end

  test "should display error message for invalid revision" do
    UserSession.new(@user)
    title = "All about balloon mapping"
    post :create, :uid => @user.id, :title => title, :body => "This is fascinating documentation about balloon mapping.", :tags => "balloon-mapping,event"
    assert_redirected_to "/wiki/" + title.parameterize

    get :revision, id: title.parameterize, vid: -3
    assert_equal flash[:error], "invalid revision -3"
  end

  test "should display all the wiki pages" do
    get :index
    assert_response :success
    assert_template :index
  end

  test "should display popular wiki pages" do
    get :popular
    assert_template :index
    assert_select "title", "Public Lab: Popular wiki pages" 
  end

  test  "should display well liked wiki pages" do
    get :liked
    assert_template :index
    assert_select "title", "Public Lab: Well-liked wiki pages"
  end

end
