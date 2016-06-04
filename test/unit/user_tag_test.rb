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

  test "should contain value with : delimiter" do
    user = rusers(:jeff)
    valid_user_tag = UserTag.new({
      uid: user.id,
      value: 'skill:Entrepreneur'
    })
    
    assert valid_user_tag.save
    assert valid_user_tag.value =~ /[a-z]*:[a-zA-Z1-9\S]*/
  end

  test "cannot contain format with : delimiter" do
    user = rusers(:jeff)
    invalid_user_tag = UserTag.new({
      uid: user.id,
      value: 'skill$Entrepreneur'
    })

    invalid_user_tag.save
    assert_nil invalid_user_tag.value =~ /[a-z]*:[a-zA-Z1-9\S]*/
  end
end
