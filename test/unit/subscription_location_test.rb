require 'test_helper'

class SubscriptionLocationTest < ActionMailer::TestCase
  test 'return collection of User records subscribed to a area inside nwlat/selat/nwlng/selng' do

    # Params order: watching_location(nwlat, selat, nwlng, selng)
    response_user = User.watching_location(90.0,34.10,12.7,178.0)
    user = users(:steff2)

    assert_equal 1, response_user.length
  end

  test 'return collection of User records subscribed to a area inside nwlat/selat/nwlng/selng with negative values' do

    # Params order: watching_location(nwlat, selat, nwlng, selng)
    response_user = User.watching_location(100.0,34.10,12.7,-10.0)
    user = users(:steff3)

    assert_equal 1, response_user.length
    assert_equal user, response_user[0]
  end

  test 'return collection of User records subscribed to a area inside nwlat/selat/nwlng/selng with multiple users' do

    # Params order: watching_location(nwlat, selat, nwlng, selng)
    response_user = User.watching_location(100.0,2.10,20.0,80.0)
    user = users(:steff2, :steff3)

    assert_equal 2, response_user.length
    assert_equal user[0], response_user[0]
    assert_equal user[1], response_user[1]
  end

  test 'location with no user subscribed' do

    # Params order: watching_location(nwlat, selat, nwlng, selng)
    response_user = User.watching_location(-10.0,2.4,0.0,80.0)

    assert_equal 0, response_user.length
  end

  test 'using wrong parameters: not a float' do
    exception = assert_raises(Exception) { User.watching_location('lat',0.0,0.0,80.0) }
    assert_equal( "Must be a float", exception.message )
  end
end
