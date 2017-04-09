require 'test_helper'

class DrupalUserTest < ActiveSupport::TestCase
  test 'basic user attributes' do
    user = users(:jeff)
    assert_equal user.notes, user.user.notes
  end

  test 'moderate and unmoderate user' do
    user = users(:bob)
    assert_equal 1, user.status
    user.moderate
    assert_equal 5, user.status
    user.unmoderate
    assert_equal 1, user.status
  end

  test 'ban and unban user' do
    user = users(:bob)
    assert_equal 1, user.status
    user.ban
    assert_equal 0, user.status
    user.unban
    assert_equal 1, user.status
  end

  test 'first time user' do
    assert        !users(:jeff).notes.empty?
    assert        !users(:jeff).first_time_poster
    assert_false  !users(:bob).notes.empty?
    assert        users(:bob).first_time_poster
    assert_false  !users(:lurker).notes.empty?
    assert        users(:lurker).first_time_poster
  end

  test 'user.barnstars' do
    user = users(:bob)
    assert_equal 0, user.user.barnstars.length
    user = users(:legacy_user)
    assert_nil user.user
  end
end
