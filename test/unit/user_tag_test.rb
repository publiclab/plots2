require 'test_helper'

class UserTagTest < ActiveSupport::TestCase
  test 'should create UserTag' do
    user = rusers(:jeff)
    user_tag = UserTag.new(uid: user.id,
                           value: 'skill:Entrepreneur')

    assert user_tag.save
    assert_not_nil user_tag.id
    assert_not_nil user_tag.uid
    assert_not_nil user_tag.value
    assert_not_nil user_tag.name # for compatibility with regular node_tags, but we should deprecate this

    # downcases:
    assert_equal 'skill:entrepreneur', user_tag.value

    assert_not_nil user.user_tags
  end

  test 'should not contains special characters in value' do
    user = rusers(:jeff)
    invalid_values = ['"', '""', "'", '$']
    invalid_values.each do |value|
      invalid_user_tag = UserTag.new(uid: user.id,
                                     value: "skill:#{value}")
      invalid_user_tag.save
      assert_equal ['Value can only include letters, numbers, and dashes'], invalid_user_tag.errors.full_messages
    end
  end
end
