require 'test_helper'
include ::ApplicationHelper

class CommentControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper

  def setup
    Timecop.freeze # account for timestamp change
    activate_authlogic
  end

  def teardown
    Timecop.return
  end

  test 'should get index with all approved comments if no user' do
    get :index
    assert_response :success
    normal_comments = assigns(:normal_comments)
    assert_not_nil normal_comments
    assert_nil assigns(:moderated_comments)
    assert normal_comments.first.timestamp > normal_comments.last.timestamp
  end

  test 'should get index with all approved comments if normal user' do
    UserSession.create(users(:bob))
    get :index
    assert_response :success
    normal_comments = assigns(:normal_comments)
    assert_not_nil normal_comments
    assert_nil assigns(:moderated_comments)
    assert normal_comments.first.timestamp > normal_comments.last.timestamp
  end

  test 'should get index with both approved and moderated comments if moderator' do
    UserSession.create(users(:jeff))
    get :index
    assert_response :success
    normal_comments = assigns(:normal_comments)
    assert_not_nil normal_comments
    assert_not_nil assigns(:moderated_comments)
    assert normal_comments.first.timestamp > normal_comments.last.timestamp
  end

  test 'should create note comments' do
    UserSession.create(users(:bob))
    node = nodes(:one)
    assert_difference 'Comment.count' do
      post :create, params: { id: node.nid, body: '[notes:awesome]' }, xhr: true
    end

    # latest_activity_nid for the node should be updated with the comment id in the format 'c_comment_id'
    cid = Comment.where(comment: '[notes:awesome]').first.cid
    expected_activity_nid = "c#{cid}"
    node_tid = node.tag.first.tid
    returned_activity_nid = Tag.where(tid: node_tid).first.latest_activity_nid

    assert_equal expected_activity_nid, returned_activity_nid
    assert_response :success
    assert_not_nil :comment
    assert_template partial: 'notes/_comment'
    assert_template partial: 'grids/_notes'
    # assert_equal 1, css_select(".comment table").size # test inline grid rendering
  end

  test 'should create a replied comment' do
    UserSession.create(users(:bob))
    initial_count = comments(:first).replied_comments.count
    assert_difference 'Comment.count' do
      post :create, params: { id: nodes(:one).nid, body: '[notes:awesome]', reply_to: comments(:first) }, xhr: true
    end
    assert_response :success
    assert_not_nil :comment
    assert_template partial: 'notes/_comment'
    assert_equal (initial_count+1), comments(:first).replied_comments.count
  end

  test 'should create question comments' do
    UserSession.create(users(:bob))
    assert_difference 'Comment.count' do
      post :create, params: { id: nodes(:question).nid, body: '[notes:awesome]', type: 'question' }, xhr: true
    end
    assert_response :success
    assert_not_nil :comment
    assert_template partial: 'notes/_comment'
    # assert_equal 1, css_select(".comment table").size # test inline grid rendering # this should pass not sure why it didnt
  end

  test 'should create wiki comments' do
    UserSession.create(users(:bob))
    assert_difference 'Comment.count' do
      assert_difference "nodes(:wiki_page).comments.count" do
        post :create, params: { id: nodes(:wiki_page).nid, body: '[notes:awesome]' }, xhr: true
      end
    end
    assert_response :success
    assert_not_nil :comment
    assert_template partial: 'grids/_notes'
    # assert_equal 1, css_select(".comment table").size # test inline grid rendering
  end

  test 'should create a replied comment on a wiki page' do
    UserSession.create(users(:bob))
    initial_count = comments(:wiki_comment).replied_comments.count
    assert_difference 'Comment.count' do
      post :create, params: { id: nodes(:wiki_page).nid, body: '[notes:awesome]', reply_to: comments(:wiki_comment) }, xhr: true
    end
    assert_response :success
    assert_not_nil :comment
    assert_equal (initial_count+1), comments(:wiki_comment).replied_comments.count
  end

  test 'should create a replied comment on a question page' do
    UserSession.create(users(:bob))
    initial_count = comments(:question).replied_comments.count
    assert_difference 'Comment.count' do
      post :create, params: { id: nodes(:question).nid, body: '[notes:awesome]', reply_to: comments(:question) }, xhr: true
    end
    assert_response :success
    assert_not_nil :comment
    assert_equal (initial_count+1), comments(:question).replied_comments.count
  end

  test 'should show error if wiki comment not saved' do
    UserSession.create(users(:bob))
    assert_no_difference 'Comment.count' do
      post :create,
          params: {
          id: nodes(:wiki_page).nid
          }
    end
    assert_equal flash[:error], 'The comment could not be saved.'
    assert_equal 'failure', @response.body
  end

  test 'should show error if node comment not saved' do
    UserSession.create(users(:bob))
    assert_no_difference 'Comment.count' do
      post :create,
          params: {
          id: nodes(:one).nid
          }, xhr: true
    end
    assert_equal flash[:error], 'The comment could not be saved.'
    assert_equal 'failure', @response.body
  end

  test 'should update note comment if user is comment author' do
    UserSession.create(users(:bob))
    comment = comments(:first)
    new_comment_body = 'New body text'
    post :update, params: { id: comment.id, body: new_comment_body }
    comment.reload
    assert_equal new_comment_body, comment.comment
    assert_redirected_to comment.node.path + '?_=' + Time.now.to_i.to_s
    assert_equal flash[:notice], 'Comment updated.'
  end

  test 'should update question comment if user is comment author' do
    UserSession.create(users(:bob))
    comment = comments(:question)
    new_comment_body = 'New question text'
    post :update, params: { id: comment.id, body: new_comment_body, type: 'question' }
    comment.reload
    assert_equal new_comment_body, comment.comment
    assert_redirected_to comment.node.path(:question) + '?_=' + Time.now.to_i.to_s
    assert_equal flash[:notice], 'Comment updated.'
  end

  test 'should update answer comment if user is comment author' do
    UserSession.create(users(:bob))
    comment = comments(:answer_comment_one)
    new_comment_body = 'New answer text'
    post :update, params: { id: comment.id, body: new_comment_body, type: 'question' }
    comment.reload
    assert_equal new_comment_body, comment.comment
    assert_redirected_to comment.answer.node.path(:question) + '?_=' + Time.now.to_i.to_s
    assert_equal flash[:notice], 'Comment updated.'
  end

  test 'should show error if update failed' do
    UserSession.create(users(:bob))
    comment = comments(:first)
    new_comment_body = ''
    post :update,
         params: {
         id: comment.id
         }
    assert_not_equal new_comment_body, comment.comment
    assert_redirected_to comment.node.path
    assert_equal flash[:error], 'The comment could not be updated.'
  end

  test 'should redirect to node path if user is not comment author' do
    UserSession.create(users(:jeff))
    comment = comments(:first)
    new_comment_body = 'New body text'
    post :update, params: { id: comment.id, body: new_comment_body }
    comment.reload
    assert_not_equal new_comment_body, comment.comment
    assert_redirected_to comment.node.path
    assert_equal flash[:error], 'Only the author of the comment can edit it.'
  end

  test 'should delete note comment if user is comment author' do
    UserSession.create(users(:bob))
    comment = comments(:first)
    assert_difference 'Comment.count', -1 do
      get :delete,
          params: {
          id: comment.id
          }, xhr: true
    end
    assert_response :success
    assert_equal 'success', @response.body
  end

  test 'should delete note comment if user is note author' do
    UserSession.create(users(:bob))
    comment = comments(:second)
    assert_difference 'Comment.count', -1 do
      get :delete,
          params: {
          id: comment.id
          }, xhr: true
    end
    assert_response :success
    assert_equal 'success', @response.body
  end

  test 'should delete note comment if user is admin' do
    UserSession.create(users(:admin))
    comment = comments(:first)
    assert_difference 'Comment.count', -1 do
      get :delete, params: { id: comment.id }, xhr: true
    end
    assert_response :success
    assert_equal 'success', @response.body
  end

  test 'should delete note comment if user is comment moderator' do
    UserSession.create(users(:moderator))
    comment = comments(:first)
    assert_difference 'Comment.count', -1 do
      get :delete,
          params: {
          id: comment.id
          }, xhr: true
    end
    assert_response :success
    assert_equal 'success', @response.body
  end

  test 'should not delete note comment if user is neither of the above' do
    UserSession.create(users(:newcomer))
    comment = comments(:first)
    assert_no_difference 'Comment.count' do
      get :delete,
          params: {
          id: comment.id
          }
    end
    assert_redirected_to '/login'
    assert_equal flash[:warning], 'Only the comment or post author can delete this comment'
  end

  test 'should delete question/answer comment if user is comment author' do
    UserSession.create(users(:bob))
    comment = comments(:first)
    assert_difference 'Comment.count', -1 do
      get :delete,
          params: {
          id: comment.id,
          type: 'question'
          }, xhr: true
    end
    assert_response :success
    assert_template 'comments/delete.js.erb'
  end

  test 'should create a comment with status 4 if user has never created anything before' do
    user = users(:user_first_time_poster)
    UserSession.create(user)

    post :create, params: { id: nodes(:one).nid, body: 'example' }, xhr: true

    comment = Comment.last
    assert_equal 4, user.id && comment.status, comment.author.id
  end

  test 'should send mail to moderator if comment has status 4' do
    UserSession.create(users(:moderator))
    post :create, params: { id: nodes(:one).nid, body: 'example', status: 4 }, xhr: true
    assert ActionMailer::Base.deliveries.collect(&:to).include?([users(:moderator).email])
  end

  test 'should not send mail to moderator if comment has status different than 4' do
    UserSession.create(users(:bob))
    post :create, params: { id: nodes(:one).nid, body: 'example' }, xhr: true

    assert_equal 1, Comment.last.status
    assert_not ActionMailer::Base.deliveries.collect(&:to).include?("comment-moderators@#{ActionMailer::Base.default_url_options[:host]}")
  end

  test 'should send mail to tag followers in the comment' do
    UserSession.create(users(:jeff))
    post :create, params: { id: nodes(:question).nid, body: 'Question #awesome', type: 'question' }, xhr: true
    assert ActionMailer::Base.deliveries.collect(&:to).include?([users(:bob).email])
    # tag followers can be found in tag_selection.yml
  end

  test 'should send mail to multiple tag followers in the comment' do
    UserSession.create(users(:jeff))
    post :create, params: { id: nodes(:question).nid, body: 'Question #everything #awesome', type: 'question' }, xhr: true
    assert ActionMailer::Base.deliveries.collect(&:to).include?([users(:bob).email])
    assert ActionMailer::Base.deliveries.collect(&:to).include?([users(:moderator).email])
    # tag followers can be found in tag_selection.yml
  end

  test 'should send notification email upon a new wiki comment' do
    UserSession.create(users(:jeff))
    post :create, params: { id: nodes(:wiki_page).nid, body: 'A comment by Jeff on a wiki page of author bob', type: 'page' }, xhr: true
    assert ActionMailer::Base.deliveries.collect(&:subject).include?("New comment on Wiki page title (#11) - #c#{Comment.last.id}")
  end

  test 'should prompt user if comment includes question mark' do
    UserSession.create(users(:jeff))
    post :create, params: { id: nodes(:blog).id, body: 'Test question?' }, xhr: true
    # assert_select 'a[href=?]', '/questions', { :count => 1, :text => 'Questions page' }
  end

  test 'render propose title template when author is logged in' do
    comment = comments(:first)
    comment.comment = '[propose:title]New Title[/propose]'
    comment.save!
    html = title_suggestion(comment)
    assert_equal html.scan('<a href="/profile/Bob">Bob</a> is suggesting an alternative title').length,1
    assert_equal html.scan('<a href="/node/update/title?id=1&title=New Title"').length,1
  end

  test 'render propose title template when author is not logged in' do
    comment = comments(:second)
    comment.comment = '[propose:title]New Title[/propose]'
    comment.save!
    html = title_suggestion(comment)
    assert_equal html.scan('<a href="/profile/jeff">jeff</a> is suggesting an alternative title').length,1
    assert_equal html.scan('<a href="/node/update/title?id=2&title=New Title"').length,0
  end

  test 'should increase likes if liked' do
    UserSession.create(users(:bob))
    comment = comments(:first)
    like_count = Like.where(likeable_id: comment.id, likeable_type: "Comment").count
    post :like_comment, params: { comment_id: comment.id, user_id: 7 }, xhr: true
    updated_like_count = Like.where(likeable_id: comment.id, likeable_type: "Comment").count
    assert_equal updated_like_count, like_count+1
  end

  test 'should decrease likes if unliked' do
    UserSession.create(users(:bob))
    comment = comments(:first)
    Like.create(likeable_id: comment.id, user_id: 1, likeable_type: "Comment")
    like_count = Like.where(likeable_id: comment.id, likeable_type: "Comment").count
    post :like_comment, params: { comment_id: comment.id, user_id: 1 }, xhr: true
    updated_like_count = Like.where(likeable_id: comment.id, likeable_type: "Comment").count
    assert_equal updated_like_count, like_count-1
  end

  test 'should not send notification email to author if notify-comment-direct:false usertag is present' do
    UserSession.create(users(:jeff))
    post :create, params: {
        id: nodes(:activity).nid,
        body: 'A comment by Jeff on note of author test_user'
    }, xhr: true

    assert_not ActionMailer::Base.deliveries.collect(&:subject).include?("New comment on #{nodes(:activity).title} (##{nodes(:activity).nid}) ")
    assert_not ActionMailer::Base.deliveries.collect(&:to).include?([users(:test_user).email])
  end

  test 'should not send notification email to another commenter if notify-comment-indirect:false usertag is present' do
    UserSession.create(users(:test_user))
    post :create, params: {
        id: nodes(:about).nid,
        body: 'A comment by test user on note of author bob'
    }, xhr: true

    assert ActionMailer::Base.deliveries.collect(&:subject).include?("New comment on #{nodes(:about).title} (##{nodes(:about).nid}) - #c#{Comment.last.id} ")
    assert ActionMailer::Base.deliveries.collect(&:to).include?([users(:jeff).email]) # notifying normal commenter
    assert_not ActionMailer::Base.deliveries.collect(&:to).include?([users(:lurker).email]) # not notifying commenter with tag as setting turned off
  end

  private

  def current_user
    users(:jeff)
  end
end
