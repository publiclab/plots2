require 'test_helper'
class TagTest < ActiveSupport::TestCase
  test "returns empty array if users are  following both the given tags and this tag" do
    tag = tags(:spam)
    given_tags = [tags(:everything)]
    assert_equal [], tag.followers_who_dont_follow_tags(given_tags)
  end

  test " returns users following this tags but not given tags" do
    # users following tag are 1,4,5
    # users following tag1 are 1,4,6
    # users following tag2 are 3,7
    tag = tags(:test)
    tag1 = tags(:awesome)
    tag2 = tags(:spam)
    given_tags = [tag1, tag2]
    assert_equal [5], tag.followers_who_dont_follow_tags(given_tags)
  end

  test 'returns all users in this tag if none is following the given tags' do
    tag = tags(:spam)
    tag2 = tags(:test)
    tag1 = tags(:awesome)
    given_tags = [tag1, tag2]
    assert_equal [3,7], tag.followers_who_dont_follow_tags(given_tags).sort
  end


end
