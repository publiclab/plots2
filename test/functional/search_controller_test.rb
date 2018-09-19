require 'test_helper'

class SearchControllerTest < ActionController::TestCase

  test "new search page at /search" do
    get :new
    assert_response :success
  end

  test "search notes at /search/notes/organizers" do
    get :notes, params: { query: 'organizers' }
    assert_response :success
    assert_equal nodes(:organizers).id, assigns(:notes).first.id
  end

  test "search notes for no results at /search/notes/somethingthathasnoresults" do
    get :notes, params: { query: 'somethingthathasnoresults' }
    assert_response :success
    assert_equal [], assigns(:notes)
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

  test "search question at /search/questions/first_timer_question" do
    get :questions, params: { query: 'first_timer_question' }
    assert_response :success
    assert_equal nodes(:first_timer_question).id, assigns(:questions).first.id
  end

  test "search places page at /search/places/map" do
    get :places, params: { query: 'map' }
    assert_response :success
  end

  test "search places at /search/places/map" do
    get :places, params: { query: 'map' }
    assert_equal nodes(:map).id, assigns(:nodes).first.id
  end

  test "search tags page at /search/tags/awesome" do
    get :tags, params: { query: 'awesome' }
    assert_response :success
  end

  test "search tags at /search/tags/awesome" do
    get :tags, params: { query: 'awesome' }
    assert_equal node_tags(:awesome).nid, assigns(:tags).first.nid
  end
end
