require 'test_helper'

class PublicPagesTest < ActionDispatch::IntegrationTest
  # we need some fixtures yo!

  test "browse front page" do
    get "/"
    assert_response :success
  end

  test "browse /research" do
    get "/research"
    assert_response :success
  end

  test "browse /about" do
    get "/about"
    assert_response :success
  end

end
