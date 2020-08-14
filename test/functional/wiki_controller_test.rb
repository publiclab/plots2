require 'test_helper'
require 'sanitize'
include ActionView::Helpers::TextHelper
include ApplicationHelper
#require "authlogic/test_case"
#include Authlogic::TestCase

class WikiControllerTest < ActionController::TestCase
  #Authlogic::Session::Base.controller = Authlogic::ControllerAdapters::RailsAdapter.new(self)

  def setup
    activate_authlogic
    UserSession.create(users(:bob))
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
    get :index, params: { sort: 'title' }

    assert_response :success
    assert assigns(:wikis).each_cons(2).all?{|i,j| "j.node_revisions.title" >= "i.node_revisions.title" }
  end

  test 'should get wiki stale pages' do
    get :stale

    assert_response :success
    assert_not_nil :wikis
  end

  test "should use existing node body as template in post form based on param 'n'" do
    UserSession.create(users(:test_user))

    get :new,
        params: {
        tags: 'one,two',
        n: nodes(:blog).id
        }

    assert_response :success
    assert_select '#taginput[value=?]', 'one,two'
    assert_select 'textarea#text-input', nodes(:blog).body
  end

  test 'should get raw wiki markup' do
    get :raw, params: { id: revisions(:one).id }

    assert_response :success
  end

  test 'should get wiki page and record unique views' do
    Impression.delete_all # clear uniques
    assert_equal 0, nodes(:about).views
    assert_equal 0, Impression.count
    nodes(:about).latest.body = '## Greetings!'
    nodes(:about).save

    assert_difference 'Impression.count', 1 do
      get :show, params: { id: nodes(:about).slug }

      assert_response :success
    end
    #assert_select '#content-raw-markdown', insert_extras(nodes(:about).body)
  end

  test 'should get root-level (/about) wiki page' do
    get :root, params: { id: 'about' }

    assert_response :success
  end

  test 'should redirect root-level requests without a matching wiki page to /tag/____' do
    get :root, params: { id: 'something' }
    assert_response :redirect
    assert_redirected_to '/tag/something'
  end

  test 'post wiki no login' do
    UserSession.find.destroy

    post :create,
        params: {
         uid:   users(:bob).id,
         title: 'All about balloon mapping',
         body:  'This is fascinating documentation about balloon mapping.',
         tags:  'balloon-mapping,event'
        }

    assert_redirected_to('/login?return_to=/wiki/create')
  end

  test 'post wiki' do
    title = 'All about balloon mapping'

    post :create,
         params: {
         uid:   users(:bob).id,
         title: title,
         body:  'This is fascinating documentation about balloon mapping.',
         tags:  'balloon-mapping,event'
         }

    assert_redirected_to '/wiki/' + title.parameterize
  end

  test 'post wiki with bad title' do
    post :create,
         params: {
         uid:   users(:bob).id,
         title: '',
         body:  'This is fascinating documentation about balloon mapping.'
         }

    assert_template 'editor/wikiRich'
    selector = css_select '.alert'
    assert_equal selector.size, 1
  end

  test 'should be able to add tag' do
    title = 'All about balloon mapping'

    post :create,
         params: {
         uid:   users(:bob).id,
         title: title,
         body:  'This is fascinating documentation about balloon mapping.',
         tags:  'balloon-mapping'
         }

         assert Node.last.has_tag('balloon-mapping')
  end

  test 'viewing edit wiki page' do
    UserSession.find.destroy if UserSession.find
    UserSession.create(users(:jeff)) # jeff user fixture is not a first-time-poster

    get :edit,
        params: {
        id: 'organizers'
        }

    assert_not users(:jeff).first_time_poster
    assert_response :success
    assert_template 'wiki/edit'
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:node)
  end

  test 'disallow viewing edit wiki page for first-timers' do
    # default bob user fixure is a first-time-poster
    assert users(:bob).first_time_poster
    get :edit,
        params: {
        id: 'chicago'
        }

    assert_equal flash[:notice], "Please post a question or other content before editing the wiki. Click <a href='https://publiclab.org/notes/tester/04-23-2016/new-moderation-system-for-first-time-posters'>here</a> to learn why."
    assert_redirected_to nodes(:place).path
  end
  
  test 'updating wiki' do
    wiki = nodes(:organizers)
    newtitle = 'New Title'

    post :update, params: { id: wiki.nid, uid: users(:bob).id, title: newtitle, body: 'Editing about Page' }

    assert_redirected_to wiki.path
    assert_equal flash[:notice], 'Edits saved.'
  end

  test 'basic user blocked from editing a locked wiki page' do
    nodes(:organizers).add_tag('locked', users(:admin)) # lock the page with a tag
    # then try editing it
    assert_difference 'Revision.count', 0 do
      post :edit,
           params: {
           id: 'organizers'
           }
    end
    assert_equal flash[:warning], "This page is <a href='/wiki/power-tags#Locking'>locked</a>, and only <a href='/wiki/moderators'>moderators</a> can edit it."
    assert_redirected_to nodes(:organizers).path
  end

  test 'basic user blocked from updating a locked wiki page' do
    nodes(:organizers).add_tag('locked', users(:admin)) # lock the page with a tag
    # then try editing it
    assert_difference 'Revision.count', 0 do
      post :update,
           params: {
           id: nodes(:organizers).id
           }
    end
    assert_equal flash[:warning], "This page is <a href='/wiki/power-tags#Locking'>locked</a>, and only <a href='/wiki/moderators'>moderators</a> can update it."
    assert_redirected_to nodes(:organizers).path
  end

  test 'updating wiki with bad title' do
    post :update,
         params: {
         id:  nodes(:organizers).id,
         uid:   users(:bob).id,
         title: ''
         }

    assert_template 'wiki/edit'
    selector = css_select '.alert'
    assert_equal selector.size, 2
  end

  test 'update root-path (/about) wiki' do
    wiki = nodes(:about)
    newtitle = 'New Title'
    assert_equal wiki.path, '/about'

    post :update, params: { id: wiki.nid, uid: users(:bob).id, title: newtitle, body: 'Editing about Page' }

    wiki.reload
    assert_redirected_to wiki.path
    assert_equal flash[:notice], 'Edits saved.'
  end

  test 'update wiki uploading new image' do
    node = nodes(:about)
    image = fixture_file_upload 'rails.png'

    post :update, params: { id: node.nid, uid: users(:bob).id, title: 'New Title', body: 'Editing about Page', image: { title: 'new image', photo: image } }

    node.reload
    assert_redirected_to node.path
    assert_equal flash[:notice], 'Edits saved.'
  end

  test 'update wiki selecting previous image' do
    node = nodes(:about)
    image = node.images.where(photo_file_name: 'filename-1.jpg').last

    post :update, params: { id: node.nid, uid: users(:bob).id, title: 'New Title', body: 'Editing about Page', main_image: image.id }

    node.reload
    assert_redirected_to node.path
    assert_equal flash[:notice], 'Edits saved.'
    assert_equal node.main_image_id, image.id
  end

  test 'update wiki selecting no image' do
    node = nodes(:about)
    node.main_image_id = 1
    node.save
    assert_equal 1, node.main_image_id

    post :update, params: { id: node.nid, uid: users(:bob).id, title: 'New Title', body: 'Editing about Page', main_image: 0 }

    node.reload
    assert_redirected_to node.path
    assert_equal flash[:notice], 'Edits saved.'
    assert_nil node.main_image_id
  end

  test 'normal user should not delete wiki page' do
    wiki = nodes(:about)

    post :delete, params: { id: wiki.nid }

    assert_equal flash[:error], 'Only admins can delete wiki pages.'
    assert_redirected_to wiki.path
  end

  test 'admin user should delete wiki page' do
    wiki = nodes(:about)
    UserSession.find.destroy
    UserSession.create(users(:admin))

    post :delete, params: { id: wiki.nid }

    assert_equal flash[:notice], 'Wiki page deleted.'
    assert_redirected_to '/dashboard'
    UserSession.find.destroy
  end



  #  test "normal user should not delete wiki revision" do
  #    post :delete_revision, id: nodes(:organizers).latest.vid
  #    assert_equal flash[:error], "Only admins can delete wiki revisions."
  #    assert_redirected_to nodes(:organizers).path
  #  end

  #  test "admin user should delete wiki revision" do
  #    UserSession.create(users(:admin))
  #    post :delete_revision, id: nodes(:organizers).latest.vid
  #    assert_equal flash[:notice], "Wiki revision deleted."
  #    assert_redirected_to nodes(:organizers).path
  #    UserSession.find.destroy
  #  end

  #  test "admin user should not delete wiki revision if its the only revision" do
  #    UserSession.create(users(:admin))
  ## this will require creating a wiki page with only one revision, to be sure
  ## this could also be done in a unit test if we add a before_destroy filter on the Revision model
  #    UserSession.find.destroy
  #  end

  #  test "admin user should not delete wiki revision if its the only revision" do
  #    UserSession.create(users(:admin))
  #  end

  test 'should display wiki pages with slug in root' do
    UserSession.find.destroy
    UserSession.create(users(:admin))

    get :root, params: { id: 'about' }

    assert_response :success
    UserSession.find.destroy
  end

  test 'should redirect to /tag/___ for requests that ask for /____' do
    UserSession.find.destroy
    UserSession.create(users(:admin))

    get :root, params: { id: 'madeup' }

    assert_redirected_to '/tag/madeup'
    UserSession.find.destroy
  end

  test 'admin should revert wiki page to parent version' do
    UserSession.find.destroy
    UserSession.create(users(:admin))
    wiki = nodes(:spam_targeted_page)

    get :revert, params: { id: wiki.latest.vid } # currently, just revert to same, which clones latest

    assert_equal flash[:notice], 'The wiki page was reverted.'
    assert_nil flash[:error]
    assert_redirected_to '/wiki/' + wiki.slug
    UserSession.find.destroy
  end

  test 'user cannot revert wiki page' do
    wiki = nodes(:spam_targeted_page)

    get :revert, params: { id: wiki.latest.vid }

    assert_equal flash[:error], 'Only moderators and admins can delete wiki pages.'
    assert_redirected_to '/wiki/' + wiki.slug
  end

  test 'should display revisions' do
    get :revisions, params: { id: nodes(:spam_targeted_page).id }

    assert_response :success
    assert_template :revisions
  end

  test 'should not error if no node exist' do
    get :revisions, params: { id: 'Invalid Node' }

    assert_template :revisions
    assert_equal flash[:error], 'Invalid wiki page. No Revisions exist for this wiki page.'
  end

  test "should not display individual revision if it's been moderated" do
    revision = revisions(:unmoderated_spam_revision)
    revision.spam

    get :revision, params: { id: revision.parent.slug, vid: revision.vid }

    assert_equal "That revision has been moderated. Please see <a href='/wiki/moderation'>the moderation page to learn more</a>.", flash[:error]
    assert_redirected_to revision.parent.path
  end

  test "should display individual revision to moderators if it's been moderated" do
    revision = revisions(:unmoderated_spam_revision)
    revision.spam

    get :revision, params: { id: revision.parent.slug, vid: revision.vid }

    assert_equal "That revision has been moderated. Please see <a href='/wiki/moderation'>the moderation page to learn more</a>.", flash[:error]
    assert_redirected_to revision.parent.path
  end

  test 'should display individual revision' do
    revision = revisions(:unmoderated_spam_revision)

    get :revision, params: { id: revision.parent.slug, vid: revision.vid }

    assert_template 'show'
    assert_response :success
    assert_not_nil assigns(:node)
    assert_not_nil assigns(:revision)
    # we subselect because for some reason the view is not returning the `<p>` and `</p>\n` wrapped
    # ... messy, but couldn't find a way to disable simple_format() on the second parameter here.
    @current_user = users(:bob) # required for below test
    assert_select 'div#content', auto_link(insert_extras(revision.render_body), sanitize: false)[3..-6]
  end

  test 'should display individual revision that is not the latest' do
    revision = revisions(:about_rev_2)

    get :revision, params: { id: revision.parent.slug, vid: revision.vid }

    assert_template 'show'
    assert_response :success
    assert_not_nil assigns(:node)
    assert_not_nil assigns(:revision)
    @current_user = users(:bob) # required for below test
    assert_select 'div#content', auto_link(insert_extras(revision.render_body), sanitize: false)[3..-6]
  end

  test 'should display individual raw revision' do
    revision = revisions(:about)

    get :raw, params: { id: revision.vid }

    assert_response :success
    assert_equal @response.body, revision.body
  end

  test 'should display error message for invalid revision' do
    get :revision, params: { id: nodes(:about).slug, vid: -3 }

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
    assert_select "title", Sanitize.clean('&#127880;') + (" Public Lab: Popular wiki pages")
  end

  test  'should display well liked wiki pages' do
    get :liked

    assert_response :success
    assert_template :index
    assert_select "title", Sanitize.clean('&#127880;') + (" Public Lab: Well-liked wiki pages")
  end

  test 'should choose I18n for wiki controller' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      get :change_locale, params: { locale: lang.to_s }

      @controller = old_controller

      wiki = nodes(:organizers)
      newtitle = 'New Title'

      post :update, params: { id: wiki.nid, uid: users(:bob).id, title: newtitle, body:  'Editing about Page' }

      wiki.reload
      assert_redirected_to wiki.path
      assert_equal flash[:notice], I18n.t('wiki_controller.edits_saved')
    end
  end

  test 'should get wiki with different title and path' do
    wiki = nodes(:wiki_page)
    slug = wiki.path.gsub('/wiki/', '')
    get :show, params: { id: slug }
    assert_response :success
  end

  test 'replacing content in a node with replace action' do
    UserSession.create(users(:jeff))
    node = nodes(:about)

    assert_difference 'Revision.count' do
      assert_difference "Node.find(#{node.id}).revisions.count" do
        get :replace, params: { id: node.id, before: 'Public', after: 'Private' }
      end
    end

    assert_equal 'All about Private Lab', Node.find(node.id).body
    assert_redirected_to node.path
  end

  test 'replacing content in a node with replace action via JavaScript/AJAX' do
    UserSession.create(users(:jeff))
    node = nodes(:about)
    assert !node.latest.body.include?('Private')
    assert node.latest.body.include?('Public')

    assert_difference 'Revision.count' do
      assert_difference "Node.find(#{node.id}).revisions.count" do
        post :replace, params: { id: node.id, before: 'Public', after: 'Private' }, xhr: true
      end
    end

    assert node.latest.body.include?('Private')
    assert !node.latest.body.include?('Public')

    assert_equal 'true', response.body
    assert_equal 'All about Private Lab', Node.find(node.id).body
    assert_response :success
  end

  test "not replacing content in a node with replace action via JavaScript/AJAX if it doesn't exist" do
    UserSession.create(users(:jeff))
    node = nodes(:about)
    assert node.latest.update_attribute('body', 'Public Lab')

    assert_difference 'Revision.count', 0 do
      assert_difference "Node.find(#{node.id}).revisions.count", 0 do
        post :replace, params: { id: node.id, before: 'Elephants', after: 'Tigers' }, xhr: true
      end
    end

    assert !node.latest.body.include?('Tigers')
    assert node.latest.body.include?('Public')

    assert_equal 'false', response.body
    assert_equal 'Public Lab', Node.find(node.id).body
    assert_response 500 # failure
  end

  test 'abtest: redirects to another page' do
    wiki = nodes(:wiki_page)
    slug = wiki.path.gsub('/wiki/', '')
    place = nodes(:place)
    wiki.add_tag("abtest:#{place.nid}", users(:bob))
    assert_equal wiki.power_tag('abtest'), place.nid.to_s

    get :show, params: { id: slug }
    # assert_response :success # we can't assert this since ~50% of the time it'll redirect
  end

  test 'redirect to non-existent page fails gracefully; no redirect' do
    wiki = nodes(:wiki_page)
    slug = wiki.path.gsub('/wiki/', '')
    blog = nodes(:blog)
    wiki.add_tag('redirect:nonsense', users(:bob))
    assert_equal wiki.power_tag('redirect'), 'nonsense'

    get :show, params: { id: slug }
    assert_response :success
  end

  test 'redirect normal user to tagged page' do
    wiki = nodes(:wiki_page)
    slug = wiki.path.gsub('/wiki/', '')
    blog = nodes(:blog)
    wiki.add_tag("redirect:#{blog.nid}", users(:bob))
    assert_equal wiki.power_tag('redirect'), blog.nid.to_s

    get :show, params: { id: slug }
    assert_redirected_to blog.path
  end

  test 'admins and moderators view redirect-tagged wiki page with flash warning' do
    wiki = nodes(:wiki_page)
    slug = wiki.path.gsub('/wiki/', '')
    blog = nodes(:blog)
    wiki.add_tag("redirect:#{blog.nid}", users(:jeff))
    assert_equal blog.nid.to_s, wiki.power_tag('redirect')
    UserSession.find.destroy if UserSession.find
    UserSession.create(users(:jeff))

    get :show, params: { id: slug }

    assert_response :success
    assert_equal "Only moderators and admins see this page, as it is redirected to <a href='#{blog.path}'>#{blog.title}</a>.
        To remove the redirect, delete the tag beginning with 'redirect:'", flash[:warning]
    UserSession.find.destroy
  end

  test 'should get methods page' do
    get :methods

    assert_response :success
    assert_not_nil :nodes
    assert_not_nil :topics
  end

  test 'should get methods page and show questions count' do
    nodes(:method).add_tag('questions:spectrometer', users(:bob))
    nodes(:method).add_tag('method', users(:bob))
    get :methods

    assert_response :success
    assert_not_nil :nodes
    assert_select "#questions-count-#{nodes(:method).id}", "#{nodes(:method).questions.count} questions"
  end

  test 'should get methods page for given topic' do
    get :methods, params: { topic: 'mining' }

    assert_response :success
    assert_not_nil :nodes
  end

  test 'should get methods page for given topic, for non-existent topic' do
    get :methods, params: { topic: 'mining' }

    assert_response :success
    assert_not_nil :nodes
    assert_equal [], assigns(:nodes)
  end

  test "Invalid date tags aren't added" do
    @user = UserSession.create(users(:jeff))
    @node = nodes(:wiki_page)
    slug = @node.path.gsub('/wiki/', '')
    @node.add_tag('date:bad', users(:jeff))

    assert_equal false, @node.has_power_tag('date')
    # assert_equal "anything goes", DateTime.strptime(@node.power_tag('date'),'%m- %d-%Y').to_date.to_s(:long)

    get :show, params: { id: slug }
    assert_response :success
  end

  test "should render comment template when comment icon is clicked" do
    wiki = nodes(:wiki_page)
    slug = wiki.path.gsub('/wiki/', '')
    get :comments, params: { id: slug }
    assert_response :success
    assert_select 'div#comments h3', /Comments/
  end

  test 'redirect path by page name' do
    wiki = nodes(:wiki_page)
    slug = wiki.path.gsub('/wiki/', '')
    wiki.add_tag("redirect:about", users(:bob))
    assert_equal wiki.power_tag('redirect'), "about"

    get :show, params: { id: slug }
    assert_redirected_to "http://test.host/about"
  end

  test 'should render a text/plain when the body of two wikis are same' do
      revisionA = revisions(:about)
      revisionB = revisions(:about_rev_4)
      get :diff, params: { a: revisionA.vid, b: revisionB.vid}
      assert_equal 'text/plain', @response.content_type
      assert_equal I18n.t('wiki_controller.lead_image_or_title_change').html_safe, @response.body
  end

  test 'should render a text/partial when the body of two wikis are same' do
      revisionA = revisions(:about)
      revisionB = revisions(:about_rev_2)
      get :diff, params: { a: revisionA.vid, b: revisionB.vid}
      assert_equal 'text/html', @response.content_type
  end

  test "should get author wikis of which none are banned" do
    user = users(:jeff)
    get :author, params: { id: user.name }
    wikis = assigns(:wikis)
    # check they are not banned
    assert wikis.all? { |wiki| wiki.status == 1 }
    # test their type
    assert wikis.none? { |wiki| wiki.type == "question" || wiki.status == "note"}
    # check correct author
    assert wikis.all? { |wiki| wiki.uid == user.uid }
  end
end
