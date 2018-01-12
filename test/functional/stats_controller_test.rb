require 'test_helper'

class StatsControllerTest < ActionController::TestCase
  test 'should assign correct value to graph_comments on GET stats' do
    Comment.delete_all
    Comment.create!(comment: 'blah', timestamp: Time.now - 1)
    get :index
    assert_equal assigns(:graph_comments), Comment.comment_weekly_tallies(52, Time.now).to_a.sort.to_json
    assert_response :success
  end

  test 'should load stats range query' do
    get :range
    assert_response :success
    assert_not_nil assigns(:notes)
    assert_not_nil assigns(:wikis)
    assert_not_nil assigns(:people)
    assert_not_equal 0, assigns(:notes)
    assert_not_equal 0, assigns(:wikis)
    assert_not_equal 0, assigns(:people)
  end

  test 'should subscriptions' do
    get :subscriptions
    assert_response :success
  end

end
