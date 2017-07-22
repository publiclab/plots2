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
include ActionView::Helpers::TextHelper
include ApplicationHelper

class WikiControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
    UserSession.create(rusers(:bob))
  end

  def teardown
    UserSession.find.destroy if UserSession.find
  end

  test 'should get wiki index' do
    get :index

    assert_response :success
    assert_not_nil :wikis
  end

  test 'should get wiki index in alphabetical order' do
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
    assert_select '#taginput[value=?]', 'one,two'
    assert_select 'textarea#text-input', node(:blog).body
  end

  test 'should get raw wiki markup' do
    get :raw, id: node_revisions(:one).id

    assert_response :success
  end

  test 'should get wiki page and record unique views' do
    Impression.delete_all # clear uniques
    assert_equal 0, node(:about).views
    assert_equal 0, Impression.count
    node(:about).latest.body = '## Greetings!'
    node(:about).save

    assert_difference 'Impression.count', 1 do
      get :show, id: node(:about).slug

      assert_response :success
    end
    #assert_select '#content-raw-markdown', insert_extras(node(:about).body)
  end

  test 'should get root-level (/about) wiki page' do
    get :root, id: 'about'

    assert_response :success
  end

  test 'post wiki no login' do
    UserSession.find.destroy

    post :create,
         uid:   rusers(:bob).id,
         title: 'All about balloon mapping',
         body:  'This is fascinating documentation about balloon mapping.',
         tags:  'balloon-mapping,event'

    assert_redirected_to('/login')
  end

  test 'post wiki' do
    title = 'All about balloon mapping'

    post :create,
         uid:   rusers(:bob).id,
         title: title,
         body:  'This is fascinating documentation about balloon mapping.',
         tags:  'balloon-mapping,event'

    assert_redirected_to '/wiki/' + title.parameterize
  end

  test 'post wiki with bad title' do
    post :create,
         uid:   rusers(:bob).id,
         title: '',
         body:  'This is fascinating documentation about balloon mapping.'

    assert_template 'wiki/edit'
    assert_select '.alert'
  end

  test 'viewing edit wiki page' do
    get :edit,
        id: 'organizers'

    assert_template 'wiki/edit'
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:node)
    assert_response :success
  end

  test 'updating wiki' do
    wiki = node(:organizers)
    newtitle = 'New Title'

    post :update,
         id:    wiki.nid,
         uid:   rusers(:bob).id,
         title: newtitle,
         body:  'Editing about Page'

    wiki.reload
    assert_redirected_to wiki.path
    assert_equal flash[:notice], 'Edits saved.'
  end

  test 'basic user blocked from editing a locked wiki page' do
    node(:organizers).add_tag('locked', rusers(:admin)) # lock the page with a tag
    # then try editing it
    assert_difference 'Revision.count', 0 do
      post :edit,
           id: 'organizers'
    end
    assert_equal flash[:warning], "This page is <a href='/wiki/power-tags#Locking'>locked</a>, and only <a href='/wiki/moderators'>moderators</a> can edit it."
    assert_redirected_to node(:organizers).path
  end

  test 'basic user blocked from updating a locked wiki page' do
    node(:organizers).add_tag('locked', rusers(:admin)) # lock the page with a tag
    # then try editing it
    assert_difference 'Revision.count', 0 do
      post :update,
           id: node(:organizers).id
    end
    assert_equal flash[:warning], "This page is <a href='/wiki/power-tags#Locking'>locked</a>, and only <a href='/wiki/moderators'>moderators</a> can update it."
    assert_redirected_to node(:organizers).path
  end

  test 'updating wiki with bad title' do
    post :update,
         id:  node(:organizers).id,
         uid:   rusers(:bob).id,
         title: ''

    assert_template 'wiki/edit'
    assert_select '.alert'
  end

  test 'update root-path (/about) wiki' do
    wiki = node(:about)
    newtitle = 'New Title'
    assert_equal wiki.path, '/about'

    post :update,
         id:    wiki.nid,
         uid:   rusers(:bob).id,
         title: newtitle,
         body:  'Editing about Page'

    wiki.reload
    assert_redirected_to wiki.path
    assert_equal flash[:notice], 'Edits saved.'
  end

  test 'update wiki uploading new image' do
    node = node(:about)
    image = fixture_file_upload 'rails.png'

    post :update,
         id:    node.nid,
         uid:   rusers(:bob).id,
         title: 'New Title',
         body:  'Editing about Page',
         image: { title: 'new image',
                  photo: image }

    node.reload
    assert_redirected_to node.path
    assert_equal flash[:notice], 'Edits saved.'
  end

  test 'update wiki selecting previous image' do
    node = node(:about)
    image = node.images.where(photo_file_name: 'filename-1.jpg').last

    post :update,
         id:             node.nid,
         uid:            rusers(:bob).id,
         title:          'New Title',
         body:           'Editing about Page',
         image_revision: image.path(:default)

    node.reload
    assert_redirected_to node.path
    assert_equal flash[:notice], 'Edits saved.'
  end

  test 'normal user should not delete wiki page' do
    wiki = node(:about)

    post :delete, id: wiki.nid

    assert_equal flash[:error], 'Only admins can delete wiki pages.'
    assert_redirected_to wiki.path
  end

  test 'admin user should delete wiki page' do
    wiki = node(:about)
    UserSession.find.destroy
    UserSession.create(rusers(:admin))

    post :delete, id: wiki.nid

    assert_equal flash[:notice], 'Wiki page deleted.'
    assert_redirected_to '/dashboard'
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
  ## this could also be done in a unit test if we add a before_destroy filter on the Revision model
  #    UserSession.find.destroy
  #  end

  #  test "admin user should not delete wiki revision if its the only revision" do
  #    UserSession.create(rusers(:admin))
  #  end

  # hmm, was this modified?
  test 'should display wiki pages with slug in root' do
    UserSession.find.destroy
    UserSession.create(rusers(:admin))

    get :root, id: 'invalid'

    assert_template file: 'public/404'
    UserSession.find.destroy
  end

  test 'admin should revert wiki page to parent version' do
    UserSession.find.destroy
    UserSession.create(rusers(:admin))
    wiki = node(:spam_targeted_page)

    get :revert, id: wiki.latest.vid # currently, just revert to same, which clones latest

    assert_equal flash[:notice], 'The wiki page was reverted.'
    assert_nil flash[:error]
    assert_redirected_to '/wiki/' + wiki.slug
    UserSession.find.destroy
  end

  test 'user cannot revert wiki page' do
    wiki = node(:spam_targeted_page)

    get :revert, id: wiki.latest.vid

    assert_equal flash[:error], 'Only moderators and admins can delete wiki pages.'
    assert_redirected_to '/wiki/' + wiki.slug
  end

  test 'should display revisions' do
    get :revisions, id: node(:spam_targeted_page).id

    assert_response :success
    assert_template :revisions
  end

  test 'should not error if no node exist' do
    get :revisions, id: 'Invalid Node'

    assert_template :revisions
    assert_equal flash[:error], 'Invalid wiki page. No Revisions exist for this wiki page.'
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

  test 'should display individual revision' do
    revision = node_revisions(:unmoderated_spam_revision)

    get :revision, id: revision.parent.slug, vid: revision.vid

    assert_template 'show'
    assert_response :success
    assert_not_nil assigns(:node)
    assert_not_nil assigns(:revision)
    # we subselect because for some reason the view is not returning the `<p>` and `</p>\n` wrapped
    # ... messy, but couldn't find a way to disable simple_format() on the second parameter here.
    assert_select 'div#content', auto_link(insert_extras(revision.render_body), sanitize: false)[3..-6]
  end

  test 'should display individual revision that is not the latest' do
    revision = node_revisions(:about_rev_2)

    get :revision, id: revision.parent.slug, vid: revision.vid

    assert_template 'show'
    assert_response :success
    assert_not_nil assigns(:node)
    assert_not_nil assigns(:revision)
    assert_select 'div#content', auto_link(insert_extras(revision.render_body), sanitize: false)[3..-6]
  end

  test 'should display individual raw revision' do
    revision = node_revisions(:about)

    get :raw, id: revision.vid

    assert_response :success
    assert_equal @response.body, revision.body
  end

  test 'should display error message for invalid revision' do
    get :revision, id: node(:about).slug, vid: -3

    assert_equal flash[:error], 'Revision not found.'
  end

  test 'should display all the wiki pages' do
    get :index

    assert_response :success
    assert_template :index
  end

  test 'should display popular wiki pages' do
    get :popular

    assert_response :success
    assert_template :index
    assert_select 'title', '&#127880; Public Lab: Popular wiki pages'
  end

  test  'should display well liked wiki pages' do
    get :liked

    assert_response :success
    assert_template :index
    assert_select 'title', '&#127880; Public Lab: Well-liked wiki pages'
  end

  test 'should choose I18n for wiki controller' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      get :change_locale, locale: lang.to_s

      @controller = old_controller

      wiki = node(:organizers)
      newtitle = 'New Title'

      post :update,
           id:    wiki.nid,
           uid:   rusers(:bob).id,
           title: newtitle,
           body:  'Editing about Page'

      wiki.reload
      assert_redirected_to wiki.path
      assert_equal flash[:notice], I18n.t('wiki_controller.edits_saved')
    end
  end

  test 'should get wiki with different title and path' do
    wiki = node(:wiki_page)
    slug = wiki.path.gsub('/wiki/', '')
    get :show, id: slug
    assert_response :success
  end

  test "should show the wiki post page if wiki page doesn't exist" do
    UserSession.create(rusers(:jeff))
    get :show, id: 'A-new-wiki-page'
    assert_response :success
    assert_template 'wiki/edit'
  end

  test 'replacing content in a node with replace action' do
    UserSession.create(rusers(:jeff))
    node = node(:about)

    assert_difference 'Revision.count' do
      assert_difference "Node.find(#{node.id}).revisions.count" do
        get :replace, id: node.id, before: 'Public', after: 'Private'
      end
    end

    assert_equal 'All about Private Lab', Node.find(node.id).body
    assert_redirected_to node.path
  end

  test 'replacing content in a node with replace action via JavaScript/AJAX' do
    UserSession.create(rusers(:jeff))
    node = node(:about)
    assert !node.latest.body.include?('Private')
    assert node.latest.body.include?('Public')

    assert_difference 'Revision.count' do
      assert_difference "Node.find(#{node.id}).revisions.count" do
        xhr :post, :replace, id: node.id, before: 'Public', after: 'Private'
      end
    end

    assert node.latest.body.include?('Private')
    assert !node.latest.body.include?('Public')

    assert_equal 'true', response.body
    assert_equal 'All about Private Lab', Node.find(node.id).body
    assert_response :success
  end

  test "not replacing content in a node with replace action via JavaScript/AJAX if it doesn't exist" do
    UserSession.create(rusers(:jeff))
    node = node(:about)
    assert node.latest.update_attribute('body', 'Public Lab')

    assert_difference 'Revision.count', 0 do
      assert_difference "Node.find(#{node.id}).revisions.count", 0 do
        xhr :post, :replace, id: node.id, before: 'Elephants', after: 'Tigers'
      end
    end

    assert !node.latest.body.include?('Tigers')
    assert node.latest.body.include?('Public')

    assert_equal 'false', response.body
    assert_equal 'Public Lab', Node.find(node.id).body
    assert_response :success
  end

  test 'abtest: redirects to another page' do
    wiki = node(:wiki_page)
    slug = wiki.path.gsub('/wiki/', '')
    place = node(:place)
    wiki.add_tag("abtest:#{place.nid}", rusers(:bob))
    assert_equal wiki.power_tag('abtest'), place.nid.to_s

    get :show, id: slug
    # assert_response :success # we can't assert this since ~50% of the time it'll redirect
  end

  test 'redirect to non-existent page fails gracefully; no redirect' do
    wiki = node(:wiki_page)
    slug = wiki.path.gsub('/wiki/', '')
    blog = node(:blog)
    wiki.add_tag('redirect:nonsense', rusers(:bob))
    assert_equal wiki.power_tag('redirect'), 'nonsense'

    get :show, id: slug
    assert_response :success
  end

  test 'redirect normal user to tagged page' do
    wiki = node(:wiki_page)
    slug = wiki.path.gsub('/wiki/', '')
    blog = node(:blog)
    wiki.add_tag("redirect:#{blog.nid}", rusers(:bob))
    assert_equal wiki.power_tag('redirect'), blog.nid.to_s

    get :show, id: slug
    assert_redirected_to blog.path
  end

  test 'admins and moderators view redirect-tagged wiki page with flash warning' do
    wiki = node(:wiki_page)
    slug = wiki.path.gsub('/wiki/', '')
    blog = node(:blog)
    wiki.add_tag("redirect:#{blog.nid}", rusers(:jeff))
    assert_equal blog.nid.to_s, wiki.power_tag('redirect')
    UserSession.find.destroy if UserSession.find
    UserSession.create(rusers(:jeff))

    get :show, id: slug

    assert_response :success
    assert_equal "Only moderators and admins see this page, as it is redirected to #{blog.title}.
        To remove the redirect, delete the tag beginning with 'redirect:'", flash[:warning]
    UserSession.find.destroy
  end

  test 'should get methods page' do
    get :methods

    assert_response :success
    assert_not_nil :nodes
    assert_not_nil :topics
  end

  test 'should get methods page for given topic' do
    get :methods, topic: 'mining'

    assert_response :success
    assert_not_nil :nodes
  end

  test 'should get methods page for given topic, for non-existent topic' do
    get :methods, topic: 'mining'

    assert_response :success
    assert_not_nil :nodes
    assert_equal [], assigns(:nodes)
  end

  test "Invalid date tags aren't added" do
    @node = node(:wiki_page)
    @node.add_tag('date:bad', rusers(:jeff))

    assert_equal false, @node.has_power_tag('date')
    # assert_equal "anything goes", DateTime.strptime(@node.power_tag('date'),'%m- %d-%Y').to_date.to_s(:long)

    get :show, id: @node.slug
    assert_response :success
  end

  test "should render comment template when a comment=true parameter is passed in the get request" do
    wiki = node(:wiki_page)
    slug = wiki.path.gsub('/wiki/', '')
    get :show, id: slug, comments: "true"
    assert_response :success
    assert_select 'div#comments h3', /Comments/
  end
end
