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

  test "should get wiki index in alphabetical order" do
    get :index, order: 'alphabetic'

    assert_response :success
    assert_not_nil :wikis
  end

  test "should use existing node body as template in post form based on param 'n'" do
    UserSession.create(rusers(:bob))

    get :new,
        tags: 'one,two',
        n: node(:blog).id

    assert_response :success
    assert_select "#taginput[value=?]", "one,two"
    assert_select "textarea#text-input", node(:blog).body
  end

  test "should get raw wiki markup" do
    get :raw, id: node_revisions(:one).id

    assert_response :success
  end

  test "should get wiki page" do
    get :show, id: node(:about).id

    assert_response :success
  end

  test "should get root-level (/about) wiki page" do
    get :root, id: 'about'

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

  test "post wiki with bad title" do

    post :create,
         uid:   rusers(:bob).id,
         title: "",
         body:  "This is fascinating documentation about balloon mapping."

    assert_template "wiki/edit"
    assert_select ".alert"
  end

  test "viewing edit wiki page" do

    get :edit,
         id: 'organizers'

    assert_template "wiki/edit"
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:node)
    assert_response :success
  end

  test "updating wiki" do
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

  test "basic user blocked from editing a locked wiki page" do
    node(:organizers).add_tag('locked', rusers(:admin)) # lock the page with a tag
    # then try editing it
    assert_difference 'DrupalNodeRevision.count', 0 do
      post :edit,
          id: 'organizers'
    end
    assert_equal flash[:warning] , "This page is <a href='/wiki/power-tags#Locking'>locked</a>, and only <a href='/wiki/moderators'>moderators</a> can edit it."
    assert_redirected_to node(:organizers).path
  end

  test "basic user blocked from updating a locked wiki page" do
    node(:organizers).add_tag('locked', rusers(:admin)) # lock the page with a tag
    # then try editing it
    assert_difference 'DrupalNodeRevision.count', 0 do
      post :update,
          id: 'organizers'
    end
    assert_equal flash[:warning] , "This page is <a href='/wiki/power-tags#Locking'>locked</a>, and only <a href='/wiki/moderators'>moderators</a> can update it."
    assert_redirected_to node(:organizers).path
  end

  test "updating wiki with bad title" do

    post :update,
         id:  node(:organizers).id,
         uid:   rusers(:bob).id,
         title: ""

    assert_template "wiki/edit"
    assert_select ".alert"
  end

  test "update root-path (/about) wiki" do
    wiki = node(:about)
    newtitle = "New Title"
    assert_equal wiki.path, "/about"

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

  test "admin should not be redirected from wiki page with redirect power tag" do
    UserSession.find.destroy
    UserSession.create(rusers(:admin))
    wiki = node(:wiki_with_redirect_tag) # TODO: create fixture for redirect tag test

    get :show, id: wiki.nid

    assert_equal flash[:notice], "Only moderators and admins see this page, as it is redirected to another page. To remove the redirect, delete the tag beginning with 'redirect:'"
    assert_nil flash[:error]
    assert_template "show"
    assert_response :success
    UserSession.find.destroy
  end

  test "should redirect users if node has a redirect power tag when visiting show path" do
    wiki = node(:wiki_with_redirect_tag)

    get :show, id: wiki.nid
    assert_redirected_to wiki.path(:redirect)
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

  test "should choose I18n for wiki controller" do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      get :change_locale, :locale => lang.to_s

      @controller = old_controller

      wiki = node(:organizers)
      newtitle = "New Title"

      post :update,
           id:    wiki.nid,
           uid:   rusers(:bob).id,
           title: newtitle,
           body:  "Editing about Page"

      wiki.reload
      assert_redirected_to wiki.path
      assert_equal flash[:notice], I18n.t('wiki_controller.edits_saved')
    end
  end

  test "should get wiki with different title and path" do
    wiki = node(:wiki_page)
    slug = wiki.path.gsub('/wiki/', '')
    get :show, id: slug
    assert_response :success
  end

  test "should show the wiki post page if wiki page doesn't exist" do
    UserSession.create(rusers(:jeff))
    get :show, id: "A-new-wiki-page"
    assert_response :success
    assert_template 'wiki/edit'
  end

  test "replacing content in a node with replace action" do
    UserSession.create(rusers(:jeff))
    node = node(:about)

    assert_difference 'DrupalNodeRevision.count' do
      assert_difference "DrupalNode.find(#{node.id}).revisions.count" do

        get :replace, id: node.id, before: "Public", after: "Private"

      end
    end

    assert_equal "All about Private Lab", DrupalNode.find(node.id).body
    assert_redirected_to node.path
  end

  test "redirect normal user to tagged page" do
    wiki = node(:wiki_page)
    slug = wiki.path.gsub('/wiki/', '')
    blog = node(:blog)
    wiki.add_tag("redirect:#{blog.nid}", rusers(:bob))
    assert_equal wiki.power_tag('redirect'), "#{blog.nid}"

    get :show, id: slug
    assert_redirected_to blog.path
  end

  test "admins and moderators view redirect-tagged wiki page with flash warning" do
    wiki = node(:wiki_page)
    slug = wiki.path.gsub('/wiki/', '')
    blog = node(:blog)
    wiki.add_tag("redirect:#{blog.nid}", rusers(:jeff))
    assert_equal "#{blog.nid}", wiki.power_tag("redirect")
    UserSession.find.destroy if UserSession.find
    UserSession.create(rusers(:jeff))

    get :show, id: slug

    assert_response :success
    assert_equal "Only moderators and admins see this page, as it is redirected to #{blog.title}.
        To remove the redirect, delete the tag beginning with 'redirect:'", flash[:warning]
    UserSession.find.destroy
  end

end
