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
include ActionView::Helpers::DateHelper # required for time_ago_in_words()

class AdminControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  def teardown
    UserSession.find.destroy if UserSession.find
  end

  test "admin should promote user role to admin" do
    UserSession.create(rusers(:jeff))
    user = rusers(:bob)
    get :promote_admin, id: user.id
    assert_equal "User '<a href='/profile/#{user.username}'>#{user.username}</a>' is now an admin.", flash[:notice]
    assert_redirected_to "/profile/" + user.username + "?_=" + Time.now.to_i.to_s
  end

  test "admin should promote user role to moderator" do
    UserSession.create(rusers(:jeff))
    user = rusers(:bob)
    get :promote_moderator, id: user.id
    assert_equal "User '<a href='/profile/#{user.username}'>#{user.username}</a>' is now a moderator.", flash[:notice]
    assert_redirected_to "/profile/" + user.username + "?_=" + Time.now.to_i.to_s
  end

  test "moderator should promote user role to moderator" do
    UserSession.create(rusers(:moderator))
    user = rusers(:jeff)
    get :promote_moderator, id: user.id
    assert_equal "User '<a href='/profile/#{user.username}'>#{user.username}</a>' is now a moderator.", flash[:notice]
    assert_redirected_to "/profile/" + user.username + "?_=" + Time.now.to_i.to_s
  end

  test "user should not promote other user role to moderator" do
    UserSession.create(rusers(:bob))
    user = rusers(:jeff)
    get :promote_moderator, id: user.id
    assert_equal "Only moderators can promote other users.", flash[:error]
    assert_redirected_to "/profile/" + user.username + "?_=" + Time.now.to_i.to_s
  end

  test "user should not promote other user role to admin" do
    UserSession.create(rusers(:bob))
    user = rusers(:moderator)
    get :promote_admin, id: user.id
    assert_equal "Only admins can promote other users to admins.", flash[:error]
    assert_redirected_to "/profile/" + user.username + "?_=" + Time.now.to_i.to_s
  end

  test "admin should demote moderator role to basic" do
    UserSession.create(rusers(:admin))
    user = rusers(:moderator)
    get :demote_basic, id: user.id
    assert_equal "User '<a href='/profile/#{user.username}'>#{user.username}</a>' is no longer a moderator.", flash[:notice]
    assert_redirected_to "/profile/" + user.username + "?_=" + Time.now.to_i.to_s
  end

  test "user should not demote other moderator role to basic" do
    UserSession.create(rusers(:bob))
    user = rusers(:moderator)
    get :demote_basic, id: user.id
    assert_equal "Only admins and moderators can demote other users.", flash[:error]
    assert_redirected_to "/profile/" + user.username + "?_=" + Time.now.to_i.to_s
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

  test "moderator user should be able to publish a moderated first timer's note" do
    UserSession.create(rusers(:moderator))
    node = node(:first_timer_note)
    assert_equal 4, node.status

    get :publish, id: node(:first_timer_note).id

    assert_equal "Post approved and published after #{time_ago_in_words(node.created_at)} in moderation. Now reach out to the new community member; thank them, just say hello, or help them revise/format their post in the comments.", flash[:notice]
    node = assigns(:node)
    assert_equal 1, node.status
    assert_equal 1, node.author.status
    assert_redirected_to node.path

    email = ActionMailer::Base.deliveries.last
    assert_equal "[PublicLab] " + node.title, email.subject
  end

  test "moderator user should be able to unspam a note" do
    UserSession.create(rusers(:moderator))
    node = node(:spam)
    assert_equal 0, node.status

    get :publish, id: node.id

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

  test "first-timer moderated note (status=4) can be approved by moderator with notice and emails" do
    UserSession.create(rusers(:admin))
    node = node(:first_timer_note)

    get :publish, id: node.id

    assert_equal "Post approved and published after #{time_ago_in_words(node.created_at)} in moderation. Now reach out to the new community member; thank them, just say hello, or help them revise/format their post in the comments.", flash[:notice]

    node = assigns(:node)
    assert_equal 1, node.status
    assert_equal 1, node.author.status
    assert_redirected_to node.path
  end

  test "first-timer moderated note (status=4) can be spammed by moderator with notice and emails" do
    UserSession.create(rusers(:admin))
    node = node(:first_timer_note)

    get :mark_spam, id: node.id

    assert_equal "Item marked as spam and author banned. You can undo this on the <a href='/spam'>spam moderation page</a>.", flash[:notice]

    node = assigns(:node)
    assert_equal 0, node.status
    assert_equal 0, node.author.status
    assert_redirected_to '/dashboard'
  end

  test "should not get /admin/queue if not logged in" do
    get :queue

    assert_redirected_to '/dashboard'
  end

  test "should get /admin/queue if moderator" do
    UserSession.create(rusers(:moderator))
    get :queue

    assert_response :success
    assert_not_nil :notes
  end

end
