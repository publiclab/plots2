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
#  self.use_instantiated_fixtures = true

  def setup
    activate_authlogic
    UserSession.create(rusers(:bob))
  end

  def new_wiki(user)
    wiki = DrupalNode.new_wiki({
         uid:   user.id, 
         type:  "page",
         title: "All about balloon mapping", 
         status: 1,
         comment: 0,
         cached_likes: 0,
         body: "This is fascinating documentation about balloon mapping."
    })
    assert wiki[0]
    wiki[1] # oddly returns an array; see unit test
  end

  def teardown
    UserSession.find.destroy if UserSession.find
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
    UserSession.find.destroy
    title = "All about balloon mapping"
    post :create, 
         uid:   rusers(:bob).id, 
         title: title, 
         body:  "This is fascinating documentation about balloon mapping.", 
         tags:  "balloon-mapping,event"
    assert_redirected_to('/login?return_to=/wiki/create')
  end

  test "post wiki" do
    title = "All about balloon mapping"
    post :create, 
         uid:   rusers(:bob).id, 
         title: title, 
         body:  "This is fascinating documentation about balloon mapping.", 
         tags:  "balloon-mapping,event"
    assert_redirected_to "/wiki/"+title.parameterize
    #assert_response :success
    #assert_template "wiki/show"
  end

  test "edit wiki" do
    wiki = new_wiki(rusers(:bob))
    # add a tag, and change the title and body
    newtitle = wiki.title + " which I amended"
    nid = DrupalNodeRevision.find_by_title(wiki.title).nid
    post :update, 
         id:    wiki.nid, 
         title: newtitle, 
         body:  "This is fascinating documentation about balloon mapping. <span id='teststring'>added content</span>", 
         tags:  "balloon-mapping,event,meetup"
    assert_redirected_to "/wiki/" + wiki.title.parameterize

    get :show, { id: wiki.title.parameterize }
    assert_response :success
    assert_equal flash[:notice], "Edits saved."
    # This is WRONG! It should be newtitle, not title, right?:
    assert_select "h1", newtitle # title should change but not URL
    # assert_select "span#teststring", "added content" # this test does not work! very frustrating. 
    # assert_select ".label", "meetup" # test for tag addition too, later
  end

  test "update wiki uploading new image" do
    node = DrupalNode.where(type: 'page').last
    image = fixture_file_upload 'rails.png'
    post :update, 
         id:    node.nid, 
         uid:   rusers(:bob).id,
         title: "New Title",
         body:  "Editing about Page", 
         image: { :title => "new image",
                  :photo => image 
                }
    assert_redirected_to node.path
    assert_equal flash[:notice], "Edits saved."
  end

  test "update wiki selecting previous image" do
    node = DrupalNode.where(type: 'page').last
    image = node.images.where(photo_file_name: 'filename-1.jpg').last
    post :update, 
         id:             node.nid,
         uid:            rusers(:bob).id,
         title:          "New Title", 
         body:           "Editing about Page",
         image_revision: image.id
    assert_redirected_to node.path
    assert_equal flash[:notice], "Edits saved."
  end

  test "normal user should not delete wiki page" do
    wiki = new_wiki(rusers(:bob))
    nid = DrupalNode.find_by_title(wiki.title).nid
    post :delete, :id => nid
    assert_equal flash[:error], "Only admins can delete wiki pages."
    assert_redirected_to "/wiki/" + wiki.title.parameterize
  end

  test "admin user should delete wiki page" do
    wiki = new_wiki(rusers(:bob))
    UserSession.find.destroy
    UserSession.create(rusers(:admin))
    post :delete, :id => wiki.nid
    assert_equal flash[:notice], "Wiki page deleted."
    assert_redirected_to "/dashboard"
    UserSession.find.destroy
  end

#  test "normal user should not delete wiki revision" do
#    post :delete_revision, id: DrupalNodeRevision.last.vid
#    assert_equal flash[:error], "Only admins can delete wiki revisions."
#    assert_redirected_to "/wiki/" + title.parameterize # use node_path?
#  end

#  test "admin user should delete wiki revision" do
#    UserSession.find.destroy
#    UserSession.create(rusers(:admin))
#    post :delete_revision, id: DrupalNodeRevision.last.vid
#    assert_equal flash[:notice], "Wiki revision deleted."
#    assert_redirected_to "/wiki/" + title.parameterize # use node_path?
#    UserSession.find.destroy
#  end

#  test "admin user should not delete wiki revision if its the only revision" do
#    UserSession.find.destroy
#    UserSession.create(rusers(:admin))
## this will require creating a wiki page with only one revision, to be sure
## this could also be done in a unit test if we add a before_destroy filter on the DrupalNodeRevision model
#    UserSession.find.destroy
#  end

  # hmm, was this modified? 
  test "should display wiki pages with slug in root" do
    UserSession.find.destroy
    UserSession.create(rusers(:admin))
    wiki = new_wiki(rusers(:bob))

    get :root, id: "invalid"
    assert_template file: 'public/404'
    UserSession.find.destroy
  end

  test "admin should revert wiki page to parent version" do
    UserSession.find.destroy
    UserSession.create(rusers(:admin))
    wiki = new_wiki(rusers(:bob))
    get :revert, id: wiki.latest.vid # currently, just revert to same, which clones latest
    assert_equal flash[:notice], "The wiki page was reverted."
    assert_nil flash[:error]
    assert_redirected_to "/wiki/" + wiki.title.parameterize
    UserSession.find.destroy
  end

  test "user cannot revert wiki page" do
    wiki = new_wiki(rusers(:bob))
    nid = DrupalNodeRevision.find_by_title(wiki.title)
    get :revert, id: wiki.vid
    assert_equal flash[:error], "Only moderators and admins can delete wiki pages."
    assert_redirected_to "/wiki/" + wiki.title.parameterize
  end

  test "should display revisions" do
    title = "All about balloon mapping"
    post :create, 
         uid:   rusers(:admin).id, 
         title: title, 
         body: "This is fascinating documentation about balloon mapping.", 
         tags: "balloon-mapping,event"
    assert_redirected_to "/wiki/" + title.parameterize

    #Edit wiki page
    newtitle = title + "Edited page"
    nid = DrupalNodeRevision.find_by_title(title).nid
    post :update,
         id:    nid, 
         title: newtitle, 
         body:  "This is fascinating documentation about balloon mapping. <span id='teststring'>added content</span>", 
         tags:  "balloon-mapping,event,meetup"
    assert_redirected_to "/wiki/" + title.parameterize

    get :revisions, id: title.parameterize
    assert_tag :tag => 'h3', :child => /Revisions for #{title}/
    assert_select 'title', "Public Lab: Revisions for &#x27;#{title}&#x27;"
    assert_template :revisions
  end

  test "should not error if no node exist" do
    title = "All about balloon mapping"
    post :create, 
         uid: rusers(:bob).id, 
         title: title, 
         body: "This is fascinating documentation about balloon mapping.", 
         tags: "balloon-mapping,event"
    assert_redirected_to "/wiki/" + title.parameterize

    get :revisions, id: "Invalid Node"
    assert_template :revisions
    assert_equal flash[:error], "Invalid wiki page. No Revisions exist for this wiki page."
  end

  test "should display individual version" do
    title = "All about balloon mapping"
    post :create,
         uid:   rusers(:bob).id, 
         title: title, 
         body:  "This is fascinating documentation about balloon mapping.", 
         tags:  "balloon-mapping,event"
    assert_redirected_to "/wiki/" + title.parameterize

    vid = DrupalNodeRevision.find_by_title(title).vid
    get :revision, id: title.parameterize, vid: vid
    assert_template "show"
  end

  test "should display error message for invalid revision" do
    title = "All about balloon mapping"
    post :create,
         uid:   rusers(:bob).id, 
         title: title, 
         body:  "This is fascinating documentation about balloon mapping.", 
         tags:  "balloon-mapping,event"
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
