require 'test_helper'

class FeaturesTest < ActionDispatch::IntegrationTest
  test 'admins may update features' do
    u = users(:admin)
    post '/user_sessions', params: { user_session: { username: u.username, password: 'secretive' } }

    get '/features/new'

    assert_response :success

    post '/features/create', params: {
      title: 'new-feature',
      body: 'This is a new feature!'
    }

    follow_redirect!
    assert_equal '/features/?_=' +
                 Time.now.strftime('%m-%d-%Y'), path

    assert Node.where(type: 'feature').last.title = 'new-feature'
  end
end
