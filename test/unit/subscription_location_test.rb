require 'test_helper'

class SubscriptionLocationTest < ActionMailer::TestCase
  test 'return collection of User records subscribed to a area inside nwlat/selat/nwlng/selng' do

    response_user = User.watching_location(250.0,0.0,0.0,250.0)
    user = users(:steff2)

    assert_equal 1, response_user.length
    assert_equal user, response_user[0]
  end
end
