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
  end

  test "search dynamic search page at /search/dynamic" do
    get :dynamic
    assert_response :success
  end

end
