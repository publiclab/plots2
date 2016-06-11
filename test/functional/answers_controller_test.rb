require 'test_helper'

class AnswersControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  test "should get create if user is logged in" do
    UserSession.create(rusers(:bob))
    node = node(:question)
    assert_difference 'Answer.count' do
      xhr :post, :create,
                 nid: node.nid,
                 body: "Sample answer"
    end
    assert_response :success
    assert_not_nil assigns(:answer)
  end

  test "should get update if user is logged in" do
    UserSession.create(rusers(:bob))
    answer = answers(:one)
    get :update, id: answer.id,
                 body: "Some changes in answer"
    assert_redirected_to answer.node.path(:question)
    assert_equal 'Answer updated', flash[:notice]
  end

  test "should show error if user is not the author of post" do
    UserSession.create(rusers(:jeff))
    answer = answers(:one)
    get :update, id: answer.id,
                 body: "Some changes"
    assert_redirected_to answer.node.path(:question)
    assert_equal 'Only the author of the answer can edit it.', flash[:error]
  end

  test "should delete answer if logged in user is question author" do
    UserSession.create(rusers(:jeff))
    answer = answers(:one)
    assert_difference 'Answer.count', -1 do
      xhr :get, :delete, id: answer.id
    end
    assert_response :success
  end

  test "should delete answer if logged in user is answer author" do
    UserSession.create(rusers(:bob))
    answer = answers(:one)
    assert_difference 'Answer.count', -1 do
      xhr :get, :delete, id: answer.id
    end
    assert_response :success
  end

  test "should delete answer if logged in user is admin" do
    UserSession.create(rusers(:admin))
    answer = answers(:one)
    assert_difference 'Answer.count', -1 do
      xhr :get, :delete, id: answer.id
    end
    assert_response :success
  end

  test "should delete answer if logged in user is moderator" do
    UserSession.create(rusers(:moderator))
    answer = answers(:one)
    assert_difference 'Answer.count', -1 do
      xhr :get, :delete, id: answer.id
    end
    assert_response :success
  end

  test "should redirect to login page if user is neither of the above" do
    UserSession.create(rusers(:newcomer))
    answer = answers(:one)
    assert_no_difference 'Answer.count' do
      xhr :get, :delete, id: answer.id
    end
    assert_redirected_to '/login'
    assert_equal 'Only the answer or question author can delete this answer', flash[:warning]
  end

end
