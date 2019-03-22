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

  test "search profiles page at /search/profiles/steff?tag=awesome" do
    get :profiles, params: { query: 'awesome', field: 'tag' }
    assert_response :success
    assert_equal users(:steff3).id, assigns(:profiles).first.id
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

  test "search for trawl trawling and trawls yields the same result" do
    get :all_content, params: { :query => "trawl" }
    nodes_with_trawl = assigns(:nodes)

    get :all_content, params: { :query => "trawling" }
    nodes_with_trawling = assigns(:nodes)

    get :all_content, params: { :query => "trawls" }
    nodes_with_trawls = assigns(:nodes)

    assert_equal nodes_with_trawl, nodes_with_trawling
    assert_equal nodes_with_trawl, nodes_with_trawls
    assert_response :success
  end

  test "search for hyphenated searches returns results for non hyphenated searches as well" do
    get :all_content, params: { :query => "purple-air" }
    nodes_with_purple_air = assigns(:nodes)

    get :all_content, params: { :query => "purpleair" }
    nodes_with_purpleair = assigns(:nodes)
    flag = false
    nodes_with_purpleair.each do |key,val|
      if nodes_with_purpleair[key].length != nodes_with_purple_air[key].length
        flag = true
      end
    end
    assert_not flag
  end
end
