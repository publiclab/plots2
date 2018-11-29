require 'test_helper'

class SearchControllerTest < ActionController::TestCase

  test "new search page at /search" do
    get :new
    assert_response :success
  end

  test "search notes at /search/notes/canon" do
    get :notes, params: { query: 'Canon' }
    assert_response :success
    assert_equal nodes(:one).id, assigns(:notes).first.id
  end

  test "search profiles page at /search/profiles/steff1" do
    get :profiles, params: { query: 'steff1' }
    assert_response :success
  end

  test "search profiles at /search/profiles/steff1" do
    get :profiles, params: { query: 'steff1' }
    assert_response :success
    assert_equal users(:steff1).id, assigns(:profiles).first.id
  end

  test "search questions page at /search/questions/question" do
    get :questions, params: { query: 'question' }
    assert_response :success
  end

  test "search question at /search/questions/question" do
    get :questions, params: { query: 'question' }
    assert_response :success
    assert_equal nodes(:question).nid, assigns(:questions).first.nid
  end

  test "search places page at /search/places/map" do
    get :places, params: { query: 'map' }
    assert_response :success
  end

  test "search tags page at /search/tags/awesome" do
    get :tags, params: { query: 'awesome' }
    assert_response :success
  end

  test "search tags at /search/tags/awesome" do
    get :tags, params: { query: 'awesome' }
    assert_response :success
    assert_equal node_tags(:awesome).nid, assigns(:tags).first.nid
  end

  test "all_content at /search/page" do
    get :all_content, params: { query: 'page' }
    assert_response :success
    assert assigns(:nodes).values.flatten.collect(&:type).uniq.length > 1
  end
end
