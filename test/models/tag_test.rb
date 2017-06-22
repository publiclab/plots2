require 'test_helper'
class TagTest < ActiveSupport::TestCase
  test "returns empty array if users are  following both the given tags and this tag" do
    tag = tags(:spam)
    given_tags = [tags(:chapter)]
    assert_equal [], tag.followers_who_dont_follow_tags(given_tags)
  end

  test " returns users following this tags but not given tags" do
    # users following tag are bob, unbanned_spammer, palpatine
    # users following tag1 are bob, palpatine, obiwan
    # users following tag2 are spammer, newcomer
    tag = tags(:test)
    tag1 = tags(:awesome)
    tag2 = tags(:spam)
    given_tags = [tag1, tag2]
    assert_equal ['palpatine'], tag.followers_who_dont_follow_tags(given_tags)
  end

  test 'returns all users in this tag if none is following the given tags' do
    tag = tags(:spam)
    tag2 = tags(:test)
    tag1 = tags(:awesome)
    given_tags = [tag1, tag2]
    assert_equal ['newcomer', 'spammer'], tag.followers_who_dont_follow_tags(given_tags).sort
  end
end
