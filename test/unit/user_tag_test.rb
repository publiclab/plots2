require 'test_helper'

class UserTagTest < ActiveSupport::TestCase

  test "should create UserTag" do
    user = rusers(:jeff)
    user_tag = UserTag.new({
      uid: user.id,
      value: 'skill:Entrepreneur'
    })

    assert user_tag.save
    assert_not_nil user_tag.id
    assert_not_nil user_tag.uid
    assert_not_nil user_tag.value

    assert_not_nil user.user_tags
  end
end
