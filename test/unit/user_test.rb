require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "user creation" do

    user = User.new({
      username: 'chris',
      password: 'science',
      password_confirmation: 'science',
      email: 'test@publiclab.org'
    })

    assert user.save({})

    assert_not_nil user.id
    assert_not_nil user.drupal_user
    assert_not_nil user.uid
    assert_not_nil user.email

  end

end
