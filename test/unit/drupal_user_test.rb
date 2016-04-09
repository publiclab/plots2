require 'test_helper'

class DrupalNodeRevisionsTest < ActiveSupport::TestCase

  test "ban and unban user" do
    user = users(:bob)
    assert_equal 1, user.status
    user.ban
    assert_equal 0, user.status
    user.unban
    assert_equal 1, user.status
  end

end
