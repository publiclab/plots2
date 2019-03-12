require 'test_helper'

class StatsControllerTest < ActionController::TestCase
  def setup
<<<<<<< HEAD
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
=======
    @start = 1.month.ago.to_time
    @end = Date.today.to_time
  end

  test 'should assign correct value to graph_notes on GET stats' do
    Node.delete_all
    Node.create!(type: 'note', title:'blah', uid: 1, status: 1)
    get :index, params: { start: @start, end: @end }
    assert_equal assigns(:graph_notes), Node.contribution_graph_making('note', @start, @end)
  end

  test 'should assign correct value to graph_wikis on GET stats' do
    Node.delete_all
    Node.create(type: 'note', title: 'blah', uid: 1, status: 1)
    Node.create(type: 'page', title: 'blahblah', uid: 1, status: 1)
    get :index, params: { start: @start, end: @end }
    assert_equal assigns(:graph_wikis), Node.contribution_graph_making('page',  @start, @end)
>>>>>>> 1d213449731fbeb492564538213d2938ff7dd7da
  end

  test 'should assign correct value to graph_comments on GET stats' do
    Comment.delete_all
    Comment.create!(comment: 'blah', timestamp: Time.now - 1)
<<<<<<< HEAD
    get :index, params: { time: @time }
    assert_equal assigns(:graph_comments), Comment.contribution_graph_making(52, @time)
=======
    get :index, params: { start: @start, end: @end }
    assert_equal assigns(:graph_comments), Comment.contribution_graph_making(@start, @end)
>>>>>>> 1d213449731fbeb492564538213d2938ff7dd7da
    assert_response :success
  end

  test 'should load stats range query' do
    get :index
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
