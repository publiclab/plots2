require 'test_helper'

class Spam2ControllerTest < ActionDispatch::IntegrationTest
  test "should get spam" do
    get spam2_spam_url
    assert_response :success
  end

end
