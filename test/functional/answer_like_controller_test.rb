require 'test_helper'

class AnswerLikeControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
  end

  test 'should get show' do
    answer = answers(:one)
    get :show, id: answer.id
    assert_response :success
  end

  test 'should get likes' do
    UserSession.create(rusers(:admin))
    answer = answers(:one)
    xhr :get, :likes, aid: answer.id
    assert_response :success
    assert_not_nil assigns(:answer)
  end

  test 'should increase cached likes if liked' do
    UserSession.create(rusers(:admin))
    answer = answers(:one)
    assert_difference 'answer.cached_likes' do
      xhr :get, :likes, aid: answer.id
      answer.reload
    end
  end

  test 'should decrease cached likes if unliked' do
    UserSession.create(rusers(:bob))
    answer = answers(:one)
    assert_difference 'answer.cached_likes', -1 do
      xhr :get, :likes, aid: answer.id
      answer.reload
    end
  end
end
