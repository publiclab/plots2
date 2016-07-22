require 'test_helper'

class CommentControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil :comments
    assert assigns(:comments).first.timestamp > assigns(:comments).last.timestamp
  end

  test "should create note comments" do
    UserSession.create(rusers(:bob))
    assert_difference 'DrupalComment.count' do
      xhr :post, :create,
                 id: node(:one).nid,
                 body: "Notes comment"
    end
    assert_response :success
    assert_not_nil :comment
    assert_template partial: "notes/_comment"
  end

  test "should create question comments" do
    UserSession.create(rusers(:bob))
    assert_difference 'DrupalComment.count' do
      xhr :post, :create,
                 id: node(:question).nid,
                 body: "Questions comment",
                 type: "question"
    end
    assert_response :success
    assert_not_nil :comment
    assert_template partial: "questions/_comment"
  end

  test "should show error if node comment not saved" do
    UserSession.create(rusers(:bob))
    assert_no_difference 'DrupalComment.count' do
      xhr :post, :create,
                 id: node(:one).nid
    end
    assert_equal flash[:error], "The comment could not be saved."
    assert_template text: "failure"
  end

  test "should create answer comments" do
    UserSession.create(rusers(:bob))
    assert_difference 'DrupalComment.count' do
      xhr :post, :answer_create,
                 aid: answers(:one).id,
                 body: "Answers comment"
    end
    assert_response :success
    assert_not_nil :comment
    assert_template partial: "questions/_comment"
  end

  test "should show error if answer comment not saved" do
    UserSession.create(rusers(:bob))
    assert_no_difference 'DrupalComment.count' do
      xhr :post, :answer_create,
                 aid: answers(:one).id
    end
    assert_equal flash[:error], "The comment could not be saved."
    assert_template text: "failure"
  end

  test "should update note comment if user is comment author" do
    UserSession.create(rusers(:bob))
    comment = comments(:first)
    new_comment_body = "New body text"
    post :update,
         id: comment.id,
         body: new_comment_body
    comment.reload
    assert_equal new_comment_body, comment.comment
    assert_redirected_to comment.node.path
    assert_equal flash[:notice], "Comment updated."
  end

  test "should update question comment if user is comment author" do
    UserSession.create(rusers(:bob))
    comment = comments(:question)
    new_comment_body = "New question text"
    post :update,
         id: comment.id,
         body: new_comment_body,
         type: "question"
    comment.reload
    assert_equal new_comment_body, comment.comment
    assert_redirected_to comment.node.path(:question)
    assert_equal flash[:notice], "Comment updated."
  end

  test "should update answer comment if user is comment author" do
    UserSession.create(rusers(:bob))
    comment = comments(:answer_comment_one)
    new_comment_body = "New answer text"
    post :update,
         id: comment.id,
         body: new_comment_body,
         type: "question"
    comment.reload
    assert_equal new_comment_body, comment.comment
    assert_redirected_to comment.answer.node.path(:question)
    assert_equal flash[:notice], "Comment updated."
  end

  test "should show error if update failed" do
    UserSession.create(rusers(:bob))
    comment = comments(:first)
    new_comment_body = ""
    post :update,
         id: comment.id
    assert_not_equal new_comment_body, comment.comment
    assert_redirected_to comment.node.path
    assert_equal flash[:error], "The comment could not be updated."
  end

  test "should redirect to node path if user is not comment author" do
    UserSession.create(rusers(:jeff))
    comment = comments(:first)
    new_comment_body = "New body text"
    post :update,
         id: comment.id,
         body: new_comment_body
    comment.reload
    assert_not_equal new_comment_body, comment.comment 
    assert_redirected_to comment.node.path
    assert_equal flash[:error], "Only the author of the comment can edit it."
  end

  test "should delete note comment if user is comment author" do
    UserSession.create(rusers(:bob))
    comment = comments(:first)
    assert_difference 'DrupalComment.count', -1 do
      xhr :get, :delete,
                id: comment.id
    end
    assert_response :success
    assert_template text: "success"
  end

  test "should delete note comment if user is note author" do
    UserSession.create(rusers(:bob))
    comment = comments(:second)
    assert_difference 'DrupalComment.count', -1 do
      xhr :get, :delete,
                id: comment.id
    end
    assert_response :success
    assert_template text: "success"
  end

  test "should delete note comment if user is admin" do
    UserSession.create(rusers(:admin))
    comment = comments(:first)
    assert_difference 'DrupalComment.count', -1 do
      xhr :get, :delete,
                id: comment.id
    end
    assert_response :success
    assert_template text: "success"
  end

  test "should delete note comment if user is comment moderator" do
    UserSession.create(rusers(:moderator))
    comment = comments(:first)
    assert_difference 'DrupalComment.count', -1 do
      xhr :get, :delete,
                id: comment.id
    end
    assert_response :success
    assert_template text: "success"
  end

  test "should not delete note comment if user is neither of the above" do
    UserSession.create(rusers(:newcomer))
    comment = comments(:first)
    assert_no_difference 'DrupalComment.count' do
      get :delete,
          id: comment.id
    end
    assert_redirected_to '/login'
    assert_equal flash[:warning], "Only the comment or post author can delete this comment"
  end

  test "should delete question/answer comment if user is comment author" do
    UserSession.create(rusers(:bob))
    comment = comments(:first)
    assert_difference 'DrupalComment.count', -1 do
      xhr :get, :delete,
                id: comment.id,
                type: 'question'
    end
    assert_response :success
    assert_template "comment/delete"
  end
end
