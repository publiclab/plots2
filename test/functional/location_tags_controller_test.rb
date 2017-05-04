require 'test_helper'

class LocationTagsControllerTest < ActionController::TestCase
  def setup
    activate_authlogic

    Geocoder.configure(lookup: :test)

    Geocoder::Lookup::Test.set_default_stub(
      [
        {
          'latitude' => 40.7143528,
          'longitude'    => -74.0059731,
          'address'      => 'New York, NY, USA',
          'state'        => 'New York',
          'state_code'   => 'NY',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ]
    )
  end

  test 'should create location tag for user' do
    UserSession.create(rusers(:jeff))
    user = rusers(:jeff)
    post :create, type: 'location', value: { lat: 40.712784, long: -74.005941 },
                  id: user.username

    assert_equal 'Location saved successfully', flash[:notice]
  end

  test 'should create location tag with only address' do
    UserSession.create(rusers(:jeff))
    user = rusers(:jeff)
    post :create, type: 'location', value: { address: 'New york City, US' }, id: user.username

    assert_equal 'Location saved successfully', flash[:notice]
  end

  test 'should return invalid input if value is empty' do
    UserSession.create(rusers(:jeff))
    user = rusers(:jeff)
    post :create, type: 'location', value: {}, id: user.username
    assert_equal 'Invalid input. Try again', assigns[:output][:errors][0]
  end

  test 'should cannot fetch location if type and value are invalid' do
    UserSession.create(rusers(:jeff))
    user = rusers(:jeff)
    post :create, type: 'abc', value: {}, id: user.username
    assert_equal 'Cannot fetch location.', assigns[:output][:errors][1]
  end

  test 'admin can modify location of target user' do
    UserSession.create(rusers(:bob))
    user = rusers(:bob)
    post :create, type: 'location', value: { address: 'New york City, US' }, id: user.username

    # Admin modifys location
    UserSession.create(rusers(:jeff))
    post :create, type: 'location', value: { address: 'New york City, US' }, id: user.username
    assert_equal 'Location saved successfully', flash[:notice]
  end

  test 'non-admin cannot modify location of another user' do
    UserSession.create(rusers(:bob))
    user = rusers(:jeff)
    post :create, type: 'location', value: { address: 'New york City, US' }, id: user.username
    assert_equal ['Only admin (or) target user can manage tags'], assigns['output']['errors']
  end
end
