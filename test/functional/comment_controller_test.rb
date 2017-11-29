require 'test_helper'

class CommentControllerTest < ActionController::TestCase
  def setup
    Timecop.freeze # account for timestamp change
    activate_authlogic
  end

  def teardown
    Timecop.return
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil :comments
    assert assigns(:comments).first.timestamp > assigns(:comments).last.timestamp
  end

  test 'should create note comments' do
    UserSession.create(users(:bob))
    assert_difference 'Comment.count' do
      xhr :post, :create,
          id: nodes(:one).nid,
          body: 'Notes comment'
    end
    assert_response :success
    assert_not_nil :comment
    assert_template partial: 'notes/_comment'
  end

  test 'should create question comments' do
    UserSession.create(users(:bob))
    assert_difference 'Comment.count' do
      xhr :post, :create,
          id: nodes(:question).nid,
          body: 'Questions comment',
          type: 'question'
    end
    assert_response :success
    assert_not_nil :comment
    assert_template partial: 'questions/_comment'
  end

  test 'should create wiki comments' do
    UserSession.create(users(:bob))
    assert_difference 'Comment.count' do
      assert_difference "nodes(:wiki_page).comments.count" do
        xhr :post, :create,
            id: nodes(:wiki_page).nid,
            body: 'Wiki comment'
      end
    end
    assert_response :success
    assert_not_nil :comment
  end

  test 'should show error if wiki comment not saved' do
    UserSession.create(users(:bob))
    assert_no_difference 'Comment.count' do
      xhr :post, :create,
          id: nodes(:wiki_page).nid
    end
    assert_equal flash[:error], 'The comment could not be saved.'
    assert_equal 'failure', @response.body
  end

  test 'should show error if node comment not saved' do
    UserSession.create(users(:bob))
    assert_no_difference 'Comment.count' do
      xhr :post, :create,
          id: nodes(:one).nid
    end
    assert_equal flash[:error], 'The comment could not be saved.'
    assert_equal 'failure', @response.body
  end

  test 'should create answer comments' do
    UserSession.create(users(:bob))
    assert_difference 'Comment.count' do
      xhr :post, :answer_create,
          aid: answers(:one).id,
          body: 'Answers comment'
    end
    assert_response :success
    assert_not_nil :comment
    assert_template partial: 'questions/_comment'
  end

  test 'should show error if answer comment not saved' do
    UserSession.create(users(:bob))
    assert_no_difference 'Comment.count' do
      xhr :post, :answer_create,
          aid: answers(:one).id
    end
    assert_equal flash[:error], 'The comment could not be saved.'
    assert_equal 'failure', @response.body
  end

  test 'should update note comment if user is comment author' do
    UserSession.create(users(:bob))
    comment = comments(:first)
    new_comment_body = 'New body text'
    post :update,
         id: comment.id,
         body: new_comment_body
    comment.reload
    assert_equal new_comment_body, comment.comment
    assert_redirected_to comment.node.path + '?_=' + Time.now.to_i.to_s
    assert_equal flash[:notice], 'Comment updated.'
  end

  test 'should update question comment if user is comment author' do
    UserSession.create(users(:bob))
    comment = comments(:question)
    new_comment_body = 'New question text'
    post :update,
         id: comment.id,
         body: new_comment_body,
         type: 'question'
    comment.reload
    assert_equal new_comment_body, comment.comment
    assert_redirected_to comment.node.path(:question) + '?_=' + Time.now.to_i.to_s
    assert_equal flash[:notice], 'Comment updated.'
  end

  test 'should update answer comment if user is comment author' do
    UserSession.create(users(:bob))
    comment = comments(:answer_comment_one)
    new_comment_body = 'New answer text'
    post :update,
         id: comment.id,
         body: new_comment_body,
         type: 'question'
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
         id: comment.id
    assert_not_equal new_comment_body, comment.comment
    assert_redirected_to comment.node.path
    assert_equal flash[:error], 'The comment could not be updated.'
  end

  test 'should redirect to node path if user is not comment author' do
    UserSession.create(users(:jeff))
    comment = comments(:first)
    new_comment_body = 'New body text'
    post :update,
         id: comment.id,
         body: new_comment_body
    comment.reload
    assert_not_equal new_comment_body, comment.comment
    assert_redirected_to comment.node.path
    assert_equal flash[:error], 'Only the author of the comment can edit it.'
  end

  test 'should delete note comment if user is comment author' do
    UserSession.create(users(:bob))
    comment = comments(:first)
    assert_difference 'Comment.count', -1 do
      xhr :get, :delete,
          id: comment.id
    end
    assert_response :success
    assert_equal 'success', @response.body
  end

  test 'should delete note comment if user is note author' do
    UserSession.create(users(:bob))
    comment = comments(:second)
    assert_difference 'Comment.count', -1 do
      xhr :get, :delete,
          id: comment.id
    end
    assert_response :success
    assert_equal 'success', @response.body
  end

  test 'should delete note comment if user is admin' do
    UserSession.create(users(:admin))
    comment = comments(:first)
    assert_difference 'Comment.count', -1 do
      xhr :get, :delete,
          id: comment.id
    end
    assert_response :success
    assert_equal 'success', @response.body
  end

  test 'should delete note comment if user is comment moderator' do
    UserSession.create(users(:moderator))
    comment = comments(:first)
    assert_difference 'Comment.count', -1 do
      xhr :get, :delete,
          id: comment.id
    end
    assert_response :success
    assert_equal 'success', @response.body
  end

  test 'should not delete note comment if user is neither of the above' do
    UserSession.create(users(:newcomer))
    comment = comments(:first)
    assert_no_difference 'Comment.count' do
      get :delete,
          id: comment.id
    end
    assert_redirected_to '/login'
    assert_equal flash[:warning], 'Only the comment or post author can delete this comment'
  end

  test 'should delete question/answer comment if user is comment author' do
    UserSession.create(users(:bob))
    comment = comments(:first)
    assert_difference 'Comment.count', -1 do
      xhr :get, :delete,
          id: comment.id,
          type: 'question'
    end
    assert_response :success
    assert_template 'comment/delete'
  end

  test 'should send mail to tag followers in the comment' do
    UserSession.create(users(:jeff))
    xhr :post, :create,
        id: nodes(:question).nid,
        body: 'Question #awesome',
        type: 'question'
    assert ActionMailer::Base.deliveries.collect(&:to).include?([users(:bob).email])
    # tag followers can be found in tag_selection.yml
  end

  test 'should send mail to multiple tag followers in the comment' do
    UserSession.create(users(:jeff))
    xhr :post, :create,
        id: nodes(:question).nid,
        body: 'Question #everything #awesome',
        type: 'question'
    assert ActionMailer::Base.deliveries.collect(&:to).include?([users(:bob).email])
    assert ActionMailer::Base.deliveries.collect(&:to).include?([users(:moderator).email])
    # tag followers can be found in tag_selection.yml
  end

  test 'should send notification email upon a new wiki comment' do
    UserSession.create(users(:jeff))
    xhr :post, :create,
        id: nodes(:wiki_page).nid,
        body: 'A comment by Jeff on a wiki page of author bob',
        type: 'page'
    assert ActionMailer::Base.deliveries.collect(&:subject).include?("New comment on 'Wiki page title'")
  end

  test 'should prompt user if comment includes question mark' do
    UserSession.create(users(:jeff))
    xhr :post, :create,
        id: nodes(:blog).id,
        body: 'Test question?'
    assert_select 'a[href=?]', '/questions', { :count => 1, :text => 'Questions page' }
  end
end
