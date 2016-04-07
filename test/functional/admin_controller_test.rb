# def promote_admin
# def promote_moderator
# def demote_basic
# def useremail
# def spam
# def mark_spam
# def publish
# def ban
# def unban
# def users
# def batch
# def migrate

require 'test_helper'

class AdminControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  def teardown
    UserSession.find.destroy if UserSession.find
  end

  test "non-registered user should not be able to see spam page" do

    get :spam

    assert_equal "You must be logged in to access this page", flash[:notice]
    assert_redirected_to "/login?return_to=/spam"
  end

  test "normal user should not be able to see spam page" do
    UserSession.create(rusers(:bob))

    get :spam

    assert_equal "Only moderators can moderate posts.", flash[:error]
    assert_redirected_to "/dashboard"
  end

  test "moderator user should be able to see spam page" do
    UserSession.create(rusers(:moderator))

    get :spam

    assert_response :success
    assert_not_nil assigns(:nodes)
  end

  test "admin user should be able to see spam page" do
    UserSession.create(rusers(:admin))

    get :spam

    assert_response :success
    assert_not_nil assigns(:nodes)
  end
 
  test "non-registered user should not be able to mark a node as spam" do
    UserSession.create(rusers(:bob))
    UserSession.find.destroy

    get :mark_spam, id: node(:one).id

    assert_equal "Only moderators can moderate posts.", flash[:error]
    node = assigns(:node)
    assert_equal 1, node.status
    assert_redirected_to node.path
  end
 
  test "normal user should not be able to mark a node as spam" do
    UserSession.create(rusers(:bob))

    get :mark_spam, id: node(:one).id

    assert_equal "Only moderators can moderate posts.", flash[:error]
    node = assigns(:node)
    assert_equal 1, node.status
    assert_redirected_to node.path
  end

  test "moderator user should be able to mark a node as spam" do
    UserSession.create(rusers(:moderator))
    node = node(:spam).publish

    get :mark_spam, id: node.id

    assert_equal "Item marked as spam and author banned. You can undo this on the <a href='/spam'>spam moderation page</a>.", flash[:notice]
    node = assigns(:node)
    assert_equal 0, node.status
    assert_equal 0, node.author.status
    assert_redirected_to "/dashboard"
  end

  test "admin user should be able to mark a node as spam" do
    UserSession.create(rusers(:admin))
    node = node(:spam).publish

    get :mark_spam, id: node.id

    assert_equal "Item marked as spam and author banned. You can undo this on the <a href='/spam'>spam moderation page</a>.", flash[:notice]
    node = assigns(:node)
    assert_equal 0, node.status
    assert_equal 0, node.author.status
    assert_redirected_to "/dashboard"
  end

  test "admin user should not be able to mark a node as spam if it's already spammed" do
    UserSession.create(rusers(:admin))
    assert_equal 0, node(:spam).status

    get :mark_spam, id: node(:spam).id

    assert_equal "Item already marked as spam and author banned. You can undo this on the <a href='/spam'>spam moderation page</a>.", flash[:notice]
    assert_equal 0, node(:spam).status
    assert_redirected_to "/dashboard"
  end

  test "normal user should not be able to unspam a note" do
    UserSession.create(rusers(:bob))

    get :publish, id: node(:spam).id

    assert_equal "Only moderators can publish posts.", flash[:error]
    assert_equal 0, node(:spam).status
    assert_redirected_to "/dashboard"
  end

  test "moderator user should be able to unspam a note" do
    UserSession.create(rusers(:moderator))

    get :publish, id: node(:spam).id

    assert_equal "Item published.", flash[:notice]
    node = assigns(:node)
    assert_equal 1, node.status
    assert_equal 1, node.author.status
    assert_redirected_to node.path
  end

  test "admin user should be able to unspam a note" do
    UserSession.create(rusers(:admin))

    get :publish, id: node(:spam).id

    assert_equal "Item published.", flash[:notice]
    node = assigns(:node)
    assert_equal 1, node.status
    assert_equal 1, node.author.status
    assert_redirected_to node.path
  end

  test "non-registered user should not be able to see spam_revisions page" do
    UserSession.create(rusers(:admin))
    UserSession.find.destroy

    get :spam_revisions

    assert_equal "You must be logged in to access this page", flash[:notice]
    assert_redirected_to "/login?return_to=/spam/revisions"
  end

  test "normal user should not be able to see spam_revisions page" do
    UserSession.create(rusers(:bob))

    get :spam_revisions

    assert_equal "Only moderators can moderate revisions.", flash[:error]
    assert_redirected_to "/dashboard"
  end

  test "moderator user should be able to see spam_revisions page" do
    UserSession.create(rusers(:moderator))

    get :spam_revisions

    assert_response :success
    assert_not_nil assigns(:revisions)
  end

  test "admin user should be able to see spam_revisions page" do
    UserSession.create(rusers(:admin))

    get :spam_revisions

    assert_response :success
    assert_not_nil assigns(:revisions)
  end

  test "admin user should be able to spam a revision" do
    UserSession.create(rusers(:admin))
    revision = node_revisions(:unmoderated_spam_revision)
    assert_equal node(:spam_targeted_page).latest.vid, revision.vid

    get :mark_spam_revision, vid: revision.vid

    assert_equal "Item marked as spam and author banned. You can undo this on the <a href='/spam/revisions'>spam moderation page</a>.", flash[:notice]
    revision = assigns(:revision)
    assert_equal 0, revision.status
    assert_equal 0, revision.author.status
    assert_not_equal node(:spam_targeted_page).latest.vid, revision.vid
    assert_redirected_to "/dashboard"
  end

  test "admin user should be able to republish a revision" do
    UserSession.create(rusers(:admin))
    revision = node_revisions(:unmoderated_spam_revision)
    assert_equal node(:spam_targeted_page).latest.vid, revision.vid
    revision.spam
    assert_not_equal node(:spam_targeted_page).latest.vid, revision.vid

    get :publish_revision, vid: revision.vid

    assert_equal "Item published.", flash[:notice]
    revision = assigns(:revision)
    assert_equal 1, revision.status
    assert_equal 1, revision.author.status
    assert_equal revision.parent.latest.vid, revision.vid
    assert_redirected_to revision.parent.path
  end

end
