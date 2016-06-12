require 'test_helper'

class SearchControllerTest < ActionController::TestCase

  test "get search/index" do
    get :index, id: 'test'
    assert_response :success
    assert_not_nil :title
    assert_not_nil :tagnames
    assert_not_nil :users
    assert_not_nil :notes
  end

  test "get search/advanced" do
    get :advanced, id: 'test'
    assert_response :success
    assert_not_nil :nodes
  end

  test "get search/typeahead" do
    get :typeahead, id: 'test'
    assert_response :success
  end

  test "get search/map" do
    get :map
    assert_response :success
  end

end
