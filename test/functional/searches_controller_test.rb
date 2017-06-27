require 'test_helper'

# main Searches tests are in /test/solr

class SearchesControllerTest < ActionController::TestCase

  test "new search page at /search" do
    get :new
    assert_response :success
  end

  test "search results page at /search/foo" do
    get :results, id: 'About'
    assert_response :success
    assert_not_nil assigns(:tagnames)
    assert_not_nil assigns(:users)
    assert_not_nil assigns(:nodes)
    assert_equal node(:about).id, assigns(:nodes).first.id
  end

  test "search dynamic search page at /search/dynamic" do
    get :dynamic
    assert_response :success
  end

end
