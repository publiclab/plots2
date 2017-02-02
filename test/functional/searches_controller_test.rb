require 'test_helper'

# main Searches tests are in /test/solr

class SearchesControllerTest < ActionController::TestCase

  test "should load stats range query" do
    get :searches
    assert_response :success
  end

end
