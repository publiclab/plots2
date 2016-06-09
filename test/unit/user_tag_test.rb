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
    assert valid_user_tag.value =~ /\A[a-z]*:[a-zA-Z1-9\S]*\Z/
  end

  test "cannot contain format with : delimiter" do
    user = rusers(:jeff)
    invalid_user_tag = UserTag.new({
      uid: user.id,
      value: 'skill$Entrepreneur'
    })

    invalid_user_tag.save
    assert_nil invalid_user_tag.value =~ /\A[a-z]*:[a-zA-Z1-9\S]*\Z/
  end

  test "should not contains special characters in value" do
    user = rusers(:jeff)
    invalid_values = ["\"", "\"\"", "'", "$"]
    invalid_values.each do |value|
      invalid_user_tag = UserTag.new({
        uid: user.id,
        value: 'skill:#{value}'
      })

      assert_equal ["Value contains invalid input"], invalid_user_tag.errors.full_messages
    end
  end

end
