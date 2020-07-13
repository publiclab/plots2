require 'test_helper'
include ActionView::Helpers::DateHelper # required for time_ago_in_words()

class AdminControllerTest < ActionController::TestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  def setup
    activate_authlogic
    Timecop.freeze # account for timestamp change
  end

  def teardown
    UserSession.find.destroy if UserSession.find
    Timecop.return
  end

  test 'admin should promote user role to admin' do
    UserSession.create(users(:jeff))
    user = users(:bob)
    get :promote_admin, params: { id: user.id }
    assert_equal "User '<a href='/profile/#{user.username}'>#{user.username}</a>' is now an admin.", flash[:notice]
    assert_redirected_to '/profile/' + user.username + '?_=' + Time.now.to_i.to_s
  end

  test 'admin should promote user role to moderator' do
    UserSession.create(users(:jeff))
    user = users(:bob)
    get :promote_moderator, params: { id: user.id }
    assert_equal "User '<a href='/profile/#{user.username}'>#{user.username}</a>' is now a moderator.", flash[:notice]
    assert_redirected_to '/profile/' + user.username + '?_=' + Time.now.to_i.to_s
  end

  test 'moderator should promote user role to moderator' do
    UserSession.create(users(:moderator))
    user = users(:jeff)
    get :promote_moderator, params: { id: user.id }
    assert_equal "User '<a href='/profile/#{user.username}'>#{user.username}</a>' is now a moderator.", flash[:notice]
    assert_redirected_to '/profile/' + user.username + '?_=' + Time.now.to_i.to_s
  end

  test 'user should not promote other user role to moderator' do
    UserSession.create(users(:bob))
    user = users(:jeff)
    get :promote_moderator, params: { id: user.id }
    assert_equal 'Only moderators can promote other users.', flash[:error]
    assert_redirected_to '/profile/' + user.username + '?_=' + Time.now.to_i.to_s
  end

  test 'user should not promote other user role to admin' do
    UserSession.create(users(:bob))
    user = users(:moderator)
    get :promote_admin, params: { id: user.id }
    assert_equal 'Only admins can promote other users to admins.', flash[:error]
    assert_redirected_to '/profile/' + user.username + '?_=' + Time.now.to_i.to_s
  end

  test 'admin should demote moderator role to basic' do
    UserSession.create(users(:admin))
    user = users(:moderator)
    get :demote_basic, params: { id: user.id }
    assert_equal "User '<a href='/profile/#{user.username}'>#{user.username}</a>' is no longer a moderator.", flash[:notice]
    assert_redirected_to '/profile/' + user.username + '?_=' + Time.now.to_i.to_s
  end
  
  test 'user should not demote other moderator role to basic' do
    UserSession.create(users(:bob))
    user = users(:moderator)
    get :demote_basic, params: { id: user.id }
    assert_equal 'Only admins and moderators can demote other users.', flash[:error]
    assert_redirected_to '/profile/' + user.username + '?_=' + Time.now.to_i.to_s
  end
  
  test 'users that have been batch-spammed are banned' do
    UserSession.create(users(:admin))
    spam_nodes = [nodes(:spam_targeted_page), nodes(:question)]
    get :batch, params: { ids: spam_nodes.collect { |node| node["nid"] }.join(",") }
    assert_redirected_to "/spam/wiki"
    # call authors data from database
    authors = spam_nodes.collect { |node| User.find(node.author.id) }
    assert authors.all? { |spammer| spammer.status == 0 }
  end

  test "batch-spammed note should be spammed and should not be presented as potential spam after redirect to /spam/wiki" do
    UserSession.create(users(:admin))
    spam_node = nodes(:about) 
    get :spam, params: { type: "wiki" }
    # node should be present on spam suggestions because it is not yet spammed
    assert_select "#n#{spam_node.nid}", 1
    get :batch, params: { ids: spam_node.nid }
    # node is no longer on /spam/wiki because it is now already spammed
    assert_select "#n#{spam_node.nid}", 0
    # call the node from database to check if spammed
    assert_equal 0, Node.find(spam_node.id).status
  end

  test 'batch spamming users should ban correct number of users and correct number of nodes' do
    UserSession.create(users(:admin))
    spam_nodes = [nodes(:spam_targeted_page), nodes(:spam)]
    authors = spam_nodes.collect { |node| node.author }
    get :batch, params: { ids: spam_nodes.collect { |node| node["nid"] }.join(",") }
    assert_redirected_to "/spam/wiki"
    assert_equal spam_nodes.length.to_s + ' nodes spammed and ' + authors.uniq.length.to_s + ' users banned.', flash[:notice]
  end
  
  test 'normal user should not be allowed to batch spam' do
    UserSession.create(users(:bob))
    spam_nodes = [nodes(:spam_targeted_page), nodes(:spam)]
    get :batch, params: { ids: spam_nodes.collect { |node| node["nid"] }.join(",") }
    assert_equal "Only admins can batch moderate.", flash[:error]
    assert_redirected_to "/dashboard"
  end
  
  test 'admin should be able to force reset user password' do
    perform_enqueued_jobs do
      UserSession.create(users(:admin))
      user = users(:bob)
      get :reset_user_password, params: { id: user.id, email: user.email }

      # Testing whether email has been sent or not
      email = ActionMailer::Base.deliveries.last
      assert_equal 'Reset your password', email.subject
      assert_equal [user.email], email.to

      assert_equal "#{user.name} should receive an email with instructions on how to reset their password. If they do not, please double check that they are using the email they registered with.", flash[:notice]
      assert_redirected_to '/profile/' + user.name
    end
  end

  test 'non-registered user should not be able to see spam page' do
    get :spam

    assert_equal 'You must be logged in to access this page', flash[:warning]
    assert_redirected_to '/login?return_to=/spam'
  end

  test 'normal user should not be able to see spam page' do
    UserSession.create(users(:bob))

    get :spam

    assert_equal 'Only moderators can moderate posts.', flash[:error]
    assert_redirected_to '/dashboard'
  end

  test 'moderator user should be able to see spam page' do
    UserSession.create(users(:moderator))

    get :spam

    assert_response :success
    assert_not_nil assigns(:nodes)
  end

  test 'admin user should be able to see spam page' do
    UserSession.create(users(:admin))

    get :spam

    assert_response :success
    assert_not_nil assigns(:nodes)
  end

  test 'non-registered user should not be able to mark a node as spam' do
    UserSession.create(users(:bob))
    UserSession.find.destroy

    get :mark_spam, params: { id: nodes(:one).id }

    assert_equal 'Only moderators can moderate posts.', flash[:error]
    node = assigns(:node)
    assert_equal 1, node.status
    assert_redirected_to node.path
  end

  test 'normal user should not be able to mark a node as spam' do
    UserSession.create(users(:bob))

    get :mark_spam, params: { id: nodes(:one).id }

    assert_equal 'Only moderators can moderate posts.', flash[:error]
    node = assigns(:node)
    assert_equal 1, node.status
    assert_redirected_to node.path
  end

  test 'moderator user should be able to mark a node as spam' do
    perform_enqueued_jobs do
      UserSession.create(users(:moderator))
      node = nodes(:spam).publish

      assert_difference 'ActionMailer::Base.deliveries.size', 0 do
        get :mark_spam, params: { id: node.id }
       
        assert_equal "Item marked as spam and author banned. You can undo this on the <a href='/spam'>spam moderation page</a>.", flash[:notice]
        node = assigns(:node)
        assert_equal 0, node.status
        assert_equal 0, node.author.status
        assert_redirected_to '/dashboard' + '?_=' + Time.now.to_i.to_s
      end
    end
  end

  test 'admin user should be able to mark a node as spam' do
    perform_enqueued_jobs do
      UserSession.create(users(:admin))
      node = nodes(:spam).publish

      get :mark_spam, params: { id: node.id }
      user = users(:moderator)
      email = AdminMailer.notify_moderators_of_spam(node, user)
      assert_emails 1 do
          email.deliver_now
      end
      assert_equal "Item marked as spam and author banned. You can undo this on the <a href='/spam'>spam moderation page</a>.", flash[:notice]
      node = assigns(:node)
      assert_equal 0, node.status
      assert_equal 0, node.author.status
      assert_redirected_to '/dashboard' + '?_=' + Time.now.to_i.to_s

      email = ActionMailer::Base.deliveries.last
      assert_not_nil email.to
      assert_not_nil email.bcc
      assert_equal ["moderators@#{request_host}"], ActionMailer::Base.deliveries.last.to
      # title same as initial for email client threading
      assert_equal '[New Public Lab poster needs moderation] ' + node.title, email.subject
    end
  end

  test "admin user should not be able to mark a node as spam if it's already spammed" do
    UserSession.create(users(:admin))
    assert_equal 0, nodes(:spam).status

    get :mark_spam, params: { id: nodes(:spam).id }

    assert_equal "Item already marked as spam and author banned. You can undo this on the <a href='/spam'>spam moderation page</a>.", flash[:notice]
    assert_equal 0, nodes(:spam).status
    assert_redirected_to '/dashboard'
  end

  test 'normal user should not be able to unspam a note' do
    UserSession.create(users(:bob))

    get :publish, params: { id: nodes(:spam).id }

    assert_equal 'Only moderators can publish posts.', flash[:error]
    assert_equal 0, nodes(:spam).status
    assert_redirected_to '/dashboard'
  end

  test "moderator user should be able to publish a moderated first timer's note" do
    perform_enqueued_jobs do
      UserSession.create(users(:moderator))
      node = nodes(:first_timer_note)
      assert_equal 4, node.status
      ActionMailer::Base.deliveries.clear

      get :publish, params: { id: nodes(:first_timer_note).id }

      assert_equal "Post approved and published after #{time_ago_in_words(node.created_at)} in moderation. Now reach out to the new community member; thank them, just say hello, or help them revise/format their post in the comments.", flash[:notice]
      node = assigns(:node)
      assert_equal 1, node.status
      assert_equal 1, node.author.status
      assert_redirected_to node.path

      #    assert_equal 2 + node.subscribers.length, ActionMailer::Base.deliveries.length

      # emails are currently in this order, but we should make tests order-independent

      # test the author notification
      email = ActionMailer::Base.deliveries.first
      assert_equal '[Public Lab] Your post was approved!', email.subject
      assert_equal [node.author.email], email.to

      # these notifications were turned off in https://github.com/publiclab/plots2/issues/6246
      # test the moderator notification
      #email = ActionMailer::Base.deliveries[1]
      #assert_equal '[New Public Lab poster needs moderation] ' + node.title, email.subject
      #assert_equal ["moderators@#{request_host}"], email.to

      # test general subscription notices
      # (we test the final one, but there are many)
      email = ActionMailer::Base.deliveries.last
      assert_equal "[PublicLab] #{node.title} (##{node.id}) ", email.subject

    end
  end

  test "moderator user should not be able to publish a note if it's already published" do
    UserSession.create(users(:moderator))
    node = nodes(:one)
    assert_equal 1, node.status

    get :publish, params: { id: node.id }

    assert_equal 'Item already published.', flash[:notice]
    assert_equal 1, node.status
    assert_redirected_to node.path
  end

  test 'moderator user should be able to unspam a note' do
    UserSession.create(users(:moderator))
    node = nodes(:spam)
    assert_equal 0, node.status

    get :publish, params: { id: node.id }

    assert_equal 'Item published.', flash[:notice]
    node = assigns(:node)
    assert_equal 1, node.status
    assert_equal 1, node.author.status
    assert_redirected_to node.path
  end

  test 'admin user should be able to unspam a note' do
    UserSession.create(users(:admin))

    get :publish, params: { id: nodes(:spam).id }

    assert_equal 'Item published.', flash[:notice]
    node = assigns(:node)
    assert_equal 1, node.status
    assert_equal 1, node.author.status
    assert_redirected_to node.path
  end

  test 'non-registered user should not be able to see spam_revisions page' do
    UserSession.create(users(:admin))
    UserSession.find.destroy

    get :spam_revisions

    assert_equal 'You must be logged in to access this page', flash[:warning]
    assert_redirected_to '/login?return_to=/spam/revisions'
  end

  test 'normal user should not be able to see spam_revisions page' do
    UserSession.create(users(:bob))

    get :spam_revisions

    assert_equal 'Only moderators can moderate revisions.', flash[:error]
    assert_redirected_to '/dashboard'
  end

  test 'moderator user should be able to see spam_revisions page' do
    UserSession.create(users(:moderator))

    get :spam_revisions

    assert_response :success
    assert_not_nil assigns(:revisions)
  end

  test 'admin user should be able to see spam_revisions page' do
    UserSession.create(users(:admin))

    get :spam_revisions

    assert_response :success
    assert_not_nil assigns(:revisions)
  end

  test 'admin user should be able to spam a revision' do
    UserSession.create(users(:admin))
    revision = revisions(:unmoderated_spam_revision)
    assert_equal nodes(:spam_targeted_page).latest.vid, revision.vid

    get :mark_spam_revision, params: { vid: revision.vid }

    assert_equal "Item marked as spam and author banned. You can undo this on the <a href='/spam/revisions'>spam moderation page</a>.", flash[:notice]
    revision = assigns(:revision)
    assert_equal 0, revision.status
    assert_equal 0, revision.author.status
    assert_not_equal nodes(:spam_targeted_page).latest.vid, revision.vid
    assert_redirected_to '/wiki/revisions/' + revision.node.slug_from_path + '?_=' + Time.now.to_i.to_s
  end

  test 'admin user should be able to republish a revision' do
    UserSession.create(users(:admin))
    revision = revisions(:unmoderated_spam_revision)
    assert_equal nodes(:spam_targeted_page).latest.vid, revision.vid
    revision.spam
    assert_not_equal nodes(:spam_targeted_page).latest.vid, revision.vid

    get :publish_revision, params: { vid: revision.vid }

    assert_equal 'Item published.', flash[:notice]
    revision = assigns(:revision)
    assert_equal 1, revision.status
    assert_equal 1, revision.author.status
    assert_equal revision.parent.latest.vid, revision.vid
    assert_redirected_to revision.parent.path
  end

  test 'first-timer moderated note (status=4) can be spammed by moderator with notice and delayed emails' do
    perform_enqueued_jobs do
      UserSession.create(users(:admin))
      node = nodes(:first_timer_note)
      ActionMailer::Base.deliveries.clear

      assert_difference 'ActionMailer::Base.deliveries.size', 0 do
        perform_enqueued_jobs do
          get :mark_spam, params: { id: node.id }
 
          assert_equal "Item marked as spam and author banned. You can undo this on the <a href='/spam'>spam moderation page</a>.", flash[:notice]
   
          node = assigns(:node)
          assert_equal 0, node.status
          assert_equal 0, node.author.status
          assert_redirected_to '/dashboard' + '?_=' + Time.now.to_i.to_s
        end
      end
    end
  end

  test 'should not get /admin/queue if not logged in' do
    get :queue

    assert_redirected_to '/dashboard'
  end

  test 'should get /admin/queue if moderator' do
    UserSession.create(users(:moderator))
    get :queue

    assert_response :success
    assert_not_nil :notes
  end

  test 'first timer question should redirect to question path when approved by admin' do
    UserSession.create(users(:admin))
    node = nodes(:first_timer_question)
    user = users(:moderator)
    assert_equal 4, node.status

    get :publish, params: { id: nodes(:first_timer_question).id }
    assert_emails 3 do
        AdminMailer.notify_author_of_approval(node, user).deliver_now
        AdminMailer.notify_moderators_of_approval(node, user).deliver_now
        SubscriptionMailer.notify_node_creation(node).deliver_now
    end

    assert_equal "Question approved and published after #{time_ago_in_words(node.created_at)} in moderation. Now reach out to the new community member; thank them, just say hello, or help them revise/format their post in the comments.", flash[:notice]
    node = assigns(:node)
    assert_equal 1, node.status
    assert_equal 1, node.author.status
    assert_redirected_to node.path(:question)
  end

  test 'should mark comment as spam if moderator' do
    UserSession.create(users(:moderator))
    comment = comments(:first)

    post :mark_comment_spam, params: { id: comment.id }

    comment = assigns(:comment)
    user = users(:moderator)

    assert_equal 0, comment.status

    assert_equal "Comment has been marked as spam and comment author has been banned. You can undo this on the <a href='/spam/comments'>spam moderation page</a>.", flash[:notice]
    assert_response :redirect
  end

  test 'should mark comment as spam if admin' do
    UserSession.create(users(:admin))
    comment = comments(:first)

    post :mark_comment_spam, params: { id: comment.id }

    comment = assigns(:comment)
    user = users(:moderator)

    assert_equal 0, comment.status

    assert_equal "Comment has been marked as spam and comment author has been banned. You can undo this on the <a href='/spam/comments'>spam moderation page</a>.", flash[:notice]
    assert_response :redirect
  end

  test 'should not mark comment as spam if no user' do
    comment = comments(:first)

    post :mark_comment_spam, params: { id: comment.id }

    assert_redirected_to '/login?return_to=/admin/mark_comment_spam/309456473'
  end

  test 'should not mark comment as spam if normal user' do
    UserSession.create(users(:bob))
    comment = comments(:first)

    post :mark_comment_spam, params: { id: comment.id }

    comment = assigns(:comment)
    assert_equal 1, comment.status
    assert_equal "Only moderators can moderate comments.", flash[:error]
    assert_response :redirect
  end

  test 'should not mark comment as spam if it is already marked as spam' do
    UserSession.create(users(:admin))
    comment = comments(:spam_comment)

    post :mark_comment_spam, params: { id: comment.id }

    comment = assigns(:comment)
    assert_equal 0, comment.status
    assert_equal "Comment already marked as spam.", flash[:notice]
    assert_response :redirect
  end

  test 'should publish comment from spam if admin' do
    UserSession.create(users(:admin))
    comment = comments(:spam_comment)
    node = comment.node
    post :publish_comment, params: { id: comment.id }

    comment = assigns(:comment)
    assert_equal 1, comment.status
    assert_equal "Comment published.", flash[:notice]
    assert_redirected_to node.path + '?_=' + Time.now.to_i.to_s
  end

  test 'should send email to comment author when it is approved (first time commenter)' do
    user = users(:admin)
    UserSession.create(user)
    comment = comments(:comment_status_4)
    node = comment.node
    post :publish_comment, params: { id: comment.id }

    email = AdminMailer.notify_author_of_comment_approval(comment, user)
    assert_emails 1 do
        email.deliver_now
    end

    assert email.body.include?("Hi! Your comment was approved by <a href='https://#{request_host}/profile/#{user.username}'>#{user.username}</a> (a <a href='https://#{request_host}/wiki/moderation'>community moderator</a>) and is now visible in the <a href='https://#{request_host}/dashboard'>Public Lab research feed</a>. Thanks for contributing to open research!")
    comment = assigns(:comment)
    assert_equal 1, comment.status
    assert_redirected_to node.path + '?_=' + Time.now.to_i.to_s
  end

  test 'should publish comment from spam if moderator' do
    UserSession.create(users(:moderator))
    comment = comments(:spam_comment)
    node = comment.node
    post :publish_comment, params: { id: comment.id }

    comment = assigns(:comment)
    assert_equal 1, comment.status
    assert_equal "Comment published.", flash[:notice]
    assert_redirected_to node.path + '?_=' + Time.now.to_i.to_s
  end

  test 'should login if want to publish comment from spam' do
    comment = comments(:spam_comment)

    post :publish_comment, params: { id: comment.id }

    assert_equal 0, comment.status
    assert_redirected_to '/login?return_to=/admin/publish_comment/3449440'
  end

  test 'should not publish comment from spam if any other user' do
    UserSession.create(users(:newcomer))
    comment = comments(:spam_comment)
    node = comment.node

    post :publish_comment, params: { id: comment.id }

    assert_equal 0, comment.status
    assert_equal "Only moderators can publish comments.", flash[:error]
    assert_redirected_to '/dashboard'
  end

  test 'should not publish comment from spam if already published' do
    UserSession.create(users(:admin))
    comment = comments(:first)
    node = comment.node

    post :publish_comment, params: { id: comment.id }

    assert_equal 1, comment.status
    assert_equal "Comment already published.", flash[:notice]
    assert_redirected_to node.path + '?_=' + Time.now.to_i.to_s
  end

  test 'non-registered user should not be able to see spam_comments page' do
    UserSession.create(users(:admin))
    UserSession.find.destroy

    get :spam_comments

    assert_equal 'You must be logged in to access this page', flash[:warning]
    assert_redirected_to '/login?return_to=/spam/comments'
  end

  test 'normal user should not be able to see spam_comments page' do
    UserSession.create(users(:bob))

    get :spam_comments

    assert_equal 'Only moderators can moderate comments.', flash[:error]
    assert_redirected_to '/dashboard'
  end

  test 'moderator user should be able to see spam_comments page' do
    UserSession.create(users(:moderator))

    get :spam_comments

    assert_response :success
    assert_not_nil assigns(:comments)
  end

  test 'admin user should be able to see spam_comments page' do
    UserSession.create(users(:admin))

    get :spam_comments

    assert_response :success
    assert_not_nil assigns(:comments)
  end

  test 'admin user should be able to view page to search users by email' do
    UserSession.create(users(:admin))

    get :useremail

    assert_response :success
  end

  test 'admin user should be able to search users by email' do
    UserSession.create(users(:admin))

    get :useremail, params: { address: 'bob@publiclab.org', include_banned: 'true' }

    assert_response :success
    assert_not_nil assigns(:users)
  end
  
  test "test digest emails to moderators" do
    UserSession.create(users(:moderator))
    post :test_digest_email_spam
    assert_redirected_to '/spam'
  end
end
