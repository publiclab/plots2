require 'test_helper'
class TagTest < ActiveSupport::TestCase
  test "it returns users following this tag but not given tags" do
    tag_followers = [1,4,5]
    following_given_tags_ids = [4]
    assert_equal [1,5], tag_followers.reject { |userid| following_given_tags_ids.include? userid }
  end
end
