require 'test_helper'

class AnswersControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
  end

  test 'should get create if user is logged in' do
    UserSession.create(users(:bob))
    node = nodes(:question)
    initial_mail_count = ActionMailer::Base.deliveries.size
    assert_difference 'Answer.count' do
      xhr :post, :create,
          nid: node.nid,
          body: 'Sample answer'
    end
    assert_not_equal initial_mail_count, ActionMailer::Base.deliveries.size
    assert ActionMailer::Base.deliveries.collect(&:to).include?([node.author.mail])
    # Used ([node.author.mail]) here instead of just (node.author.mail) because .collect(:to) is an array of arrays
    assert_response :success
    assert_not_nil assigns(:answer)
  end

  test 'Users with subscription=everything should also be emailed ' do
    UserSession.create(users(:bob))
    node = nodes(:question)
    initial_mail_count = ActionMailer::Base.deliveries.size
    assert_difference 'Answer.count' do
      xhr :post, :create,
          nid: node.nid,
          body: 'Sample answer by the current user'
    end

    user_with_everything_tag = users(:moderator)
    assert_not_equal initial_mail_count, ActionMailer::Base.deliveries.size
    assert ActionMailer::Base.deliveries.collect(&:to).include?([user_with_everything_tag.email])
    assert_response :success
  end

  test 'should get update if user is logged in' do
    UserSession.create(users(:bob))
    answer = answers(:one)
    get :update, id: answer.id,
                 body: 'Some changes in answer'
    assert_redirected_to answer.node.path(:question)
    assert_equal 'Answer updated', flash[:notice]
  end

  test 'should show error if user is not the author of post' do
    UserSession.create(users(:jeff))
    answer = answers(:one)
    get :update, id: answer.id,
                 body: 'Some changes'
    assert_redirected_to answer.node.path(:question)
    assert_equal 'Only the author of the answer can edit it.', flash[:error]
  end

  test 'should delete answer if logged in user is question author' do
    UserSession.create(users(:jeff))
    answer = answers(:one)
    assert_difference 'Answer.count', -1 do
      xhr :get, :delete, id: answer.id
    end
    assert_response :success
  end

  test 'should delete answer if logged in user is answer author' do
    UserSession.create(users(:bob))
    answer = answers(:one)
    assert_difference 'Answer.count', -1 do
      xhr :get, :delete, id: answer.id
    end
    assert_response :success
  end

  test 'should delete answer if logged in user is admin' do
    UserSession.create(users(:admin))
    answer = answers(:one)
    assert_difference 'Answer.count', -1 do
      xhr :get, :delete, id: answer.id
    end
    assert_response :success
  end

  test 'should delete answer if logged in user is moderator' do
    UserSession.create(users(:moderator))
    answer = answers(:one)
    assert_difference 'Answer.count', -1 do
      xhr :get, :delete, id: answer.id
    end
    assert_response :success
  end

  test 'should redirect to login page if user is neither of the above' do
    UserSession.create(users(:newcomer))
    answer = answers(:one)
    assert_no_difference 'Answer.count' do
      xhr :get, :delete, id: answer.id
    end
    assert_redirected_to '/login'
    assert_equal 'Only the answer or question author can delete this answer', flash[:warning]
  end

  test 'should accept an answer which the question author approves' do
    UserSession.create(users(:jeff))
    answer = answers(:one)
    assert !answer.accepted
    xhr :get, :accept, id: answer.id
    answer.reload
    assert_response :success
    assert answer.accepted
  end

  test 'should not accept an answer by an user other than the question author' do
    UserSession.create(users(:bob))
    answer = answers(:one)
    assert !answer.accepted
    xhr :get, :accept, id: answer.id
    answer.reload
    assert !answer.accepted
    assert_equal "Answer couldn't be accepted", response.body
  end
  
  test 'should allow accepting answer if logged in user is moderator' do
    UserSession.create(users(:moderator))
    answer = answers(:one)
    answer.accepted = false
    answer.save
    assert !answer.accepted
    xhr :get, :accept, id: answer.id
    answer.reload
    assert_response :success
    assert answer.accepted
  end

end
