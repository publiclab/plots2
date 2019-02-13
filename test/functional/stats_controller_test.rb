require 'test_helper'

class StatsControllerTest < ActionController::TestCase
  def setup
    @time = Date.today.to_time
  end

  test 'should assign correct value to graph_notes on GET stats' do
      Node.delete_all
      Node.create!(type: 'note', title:'blah', uid: 1, status: 1)
      get :index, params: { time: @time }
      assert_equal assigns(:graph_notes), Node.contribution_graph_making('note', 52, @time)
  end

  test 'should assign correct value to graph_wikis on GET stats' do
      Node.delete_all
      Node.create(type: 'note', title: 'blah', uid: 1, status: 1)
      Node.create(type: 'page', title: 'blahblah', uid: 1, status: 1)
      get :index, params: { time: @time }
      assert_equal assigns(:graph_wikis), Node.contribution_graph_making('page', 52, @time)
  end

  test 'should assign correct value to graph_comments on GET stats' do
    Comment.delete_all
    Comment.create!(comment: 'blah', timestamp: Time.now - 1)
    get :index, params: { time: @time }
    assert_equal assigns(:graph_comments), Comment.contribution_graph_making(52, @time)
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
