require 'test_helper'

class AnswerLikeControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
  end

  test 'should get show' do
    perform_enqueued_jobs do
      answer = answers(:one)
      get :show, params: { id: answer.id }
      assert_response :success
    end
  end

  test 'should get likes' do
    perform_enqueued_jobs do
      UserSession.create(users(:admin))
      answer = answers(:one)
      get :likes, params: { aid: answer.id }, xhr: true
      assert_response :success
      assert_not_nil assigns(:answer)
    end
  end

  test 'should increase cached likes if liked' do
    perform_enqueued_jobs do
      UserSession.create(users(:admin))
      answer = answers(:one)
      assert_difference 'answer.cached_likes' do
        get :likes, params: { aid: answer.id }, xhr: true
        answer.reload
      end
    end
  end

  test 'should decrease cached likes if unliked' do
    perform_enqueued_jobs do
      UserSession.create(users(:bob))
      answer = answers(:one)
      assert_difference 'answer.cached_likes', -1 do
        get :likes, params: { aid: answer.id }, xhr: true
        answer.reload
      end
    end
  end
end
