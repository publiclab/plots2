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

  def setup
    activate_authlogic
    UserSession.create(rusers(:bob))
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
    get :raw, id: node_revisions(:one).id

    assert_response :success
  end

  test "should get wiki page" do
    get :show, id: node(:about).id

    assert_response :success
  end

  test "post wiki no login" do
    UserSession.find.destroy

    post :create, 
         uid:   rusers(:bob).id, 
         title: "All about balloon mapping", 
         body:  "This is fascinating documentation about balloon mapping.", 
         tags:  "balloon-mapping,event"

    assert_redirected_to('/login')
  end

  test "post wiki" do
    title = "All about balloon mapping"

    post :create, 
         uid:   rusers(:bob).id, 
         title: title, 
         body:  "This is fascinating documentation about balloon mapping.", 
         tags:  "balloon-mapping,event"

    assert_redirected_to "/wiki/" + title.parameterize
  end

  test "update wiki" do
    wiki = node(:organizers)
    newtitle = "New Title"

    post :update, 
         id:    wiki.nid, 
         uid:   rusers(:bob).id,
         title: newtitle,
         body:  "Editing about Page"

    wiki.reload
    assert_redirected_to wiki.path
    assert_equal flash[:notice], "Edits saved."
  end

  test "update root-path (/about) wiki" do
    wiki = node(:about)
    newtitle = "New Title"

    post :update, 
         id:    wiki.nid, 
         uid:   rusers(:bob).id,
         title: newtitle,
         body:  "Editing about Page"

    wiki.reload
    assert_redirected_to wiki.path
    assert_equal flash[:notice], "Edits saved."
  end

  test "update wiki uploading new image" do
    node = node(:about)
    image = fixture_file_upload 'rails.png'

    post :update, 
         id:    node.nid, 
         uid:   rusers(:bob).id,
         title: "New Title",
         body:  "Editing about Page", 
         image: { :title => "new image",
                  :photo => image 
                }

    node.reload
    assert_redirected_to node.path
    assert_equal flash[:notice], "Edits saved."
  end

  test "update wiki selecting previous image" do
    node = node(:about)
    image = node.images.where(photo_file_name: 'filename-1.jpg').last

    post :update, 
         id:             node.nid,
         uid:            rusers(:bob).id,
         title:          "New Title", 
         body:           "Editing about Page",
         image_revision: image.path(:default)

    node.reload
    assert_redirected_to node.path
    assert_equal flash[:notice], "Edits saved."
  end

  test "normal user should not delete wiki page" do
    wiki = node(:about)

    post :delete, id: wiki.nid

    assert_equal flash[:error], "Only admins can delete wiki pages."
    assert_redirected_to wiki.path
  end

  test "admin user should delete wiki page" do
    wiki = node(:about)
    UserSession.find.destroy
    UserSession.create(rusers(:admin))

    post :delete, :id => wiki.nid

    assert_equal flash[:notice], "Wiki page deleted."
    assert_redirected_to "/dashboard"
    UserSession.find.destroy
  end

#  test "normal user should not delete wiki revision" do
#    post :delete_revision, id: node(:organizers).latest.vid
#    assert_equal flash[:error], "Only admins can delete wiki revisions."
#    assert_redirected_to node(:organizers).path
#  end

#  test "admin user should delete wiki revision" do
#    UserSession.create(rusers(:admin))
#    post :delete_revision, id: node(:organizers).latest.vid
#    assert_equal flash[:notice], "Wiki revision deleted."
#    assert_redirected_to node(:organizers).path
#    UserSession.find.destroy
#  end

#  test "admin user should not delete wiki revision if its the only revision" do
#    UserSession.create(rusers(:admin))
## this will require creating a wiki page with only one revision, to be sure
## this could also be done in a unit test if we add a before_destroy filter on the DrupalNodeRevision model
#    UserSession.find.destroy
#  end

#  test "admin user should not delete wiki revision if its the only revision" do
#    UserSession.create(rusers(:admin))
#  end

  # hmm, was this modified? 
  test "should display wiki pages with slug in root" do
    UserSession.find.destroy
    UserSession.create(rusers(:admin))

    get :root, id: "invalid"

    assert_template file: 'public/404'
    UserSession.find.destroy
  end

  test "admin should revert wiki page to parent version" do
    UserSession.find.destroy
    UserSession.create(rusers(:admin))
    wiki = node(:spam_targeted_page)

    get :revert, id: wiki.latest.vid # currently, just revert to same, which clones latest

    assert_equal flash[:notice], "The wiki page was reverted."
    assert_nil flash[:error]
    assert_redirected_to "/wiki/" + wiki.slug
    UserSession.find.destroy
  end

  test "user cannot revert wiki page" do
    wiki = node(:spam_targeted_page)

    get :revert, id: wiki.latest.vid

    assert_equal flash[:error], "Only moderators and admins can delete wiki pages."
    assert_redirected_to "/wiki/" + wiki.slug
  end

  test "should display revisions" do
    get :revisions, id: node(:spam_targeted_page).id

    assert_response :success
    assert_template :revisions
  end

  test "should not error if no node exist" do

    get :revisions, id: "Invalid Node"

    assert_template :revisions
    assert_equal flash[:error], "Invalid wiki page. No Revisions exist for this wiki page."
  end

  test "should not display individual revision if it's been moderated" do
    revision = node_revisions(:unmoderated_spam_revision)
    revision.spam

    get :revision, id: revision.parent.slug, vid: revision.vid

    assert_equal "That revision has been moderated. Please see <a href='/wiki/moderation'>the moderation page to learn more</a>.", flash[:error]
    assert_redirected_to revision.parent.path
  end

  test "should display individual revision to moderators if it's been moderated" do
    revision = node_revisions(:unmoderated_spam_revision)
    revision.spam

    get :revision, id: revision.parent.slug, vid: revision.vid

    assert_equal "That revision has been moderated. Please see <a href='/wiki/moderation'>the moderation page to learn more</a>.", flash[:error]
    assert_redirected_to revision.parent.path
  end

  test "should display individual revision" do
    revision = node_revisions(:unmoderated_spam_revision)

    get :revision, id: revision.parent.slug, vid: revision.vid

    assert_template "show"
    assert_response :success
    assert_not_nil assigns(:node)
    assert_not_nil assigns(:revision)
  end

  test "should display error message for invalid revision" do
    get :revision, id: node(:about).slug, vid: -3

    assert_equal flash[:error], "Revision not found."
  end

  test "should display all the wiki pages" do
    get :index

    assert_response :success
    assert_template :index
  end

  test "should display popular wiki pages" do
    get :popular

    assert_response :success
    assert_template :index
    assert_select "title", "Public Lab: Popular wiki pages" 
  end

  test  "should display well liked wiki pages" do
    get :liked

    assert_response :success
    assert_template :index
    assert_select "title", "Public Lab: Well-liked wiki pages"
  end

end
