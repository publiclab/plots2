require 'test_helper'

class LoginFlowTest < ActionDispatch::IntegrationTest

  test 'attempt to openid authenticate (like from MapKnitter) without being logged in' do
  end

  test 'incorrect openid authentication request shows error' do

    # log in
    post '/user_sessions', params: { user_session: { username: users(:jeff).username, password: 'secretive' } }
    follow_redirect!

    get '/openid', params: {
      'openid.claimed_id': 'https://spectralworkbench.org/openid/warren',
      'openid.identity': 'https://spectralworkbench.org/openid/warren',
      'openid.mode': 'checkid_setup',
      'openid.ns': 'http://specs.openid.net/auth/2.0',
      'openid.ns.sreg': 'http://openid.net/extensions/sreg/1.1',
      'openid.realm': 'https://spectralworkbench.org/',
      'openid.return_to': 'https://spectralworkbench.org/session/new?authenticity_token=RcLcGH3lzSTCC24UpPnNm56sllNaMrHg5%2FSrQzNxB%2B4%3D&back_to=&open_id=warren&return_to=',
      'openid.sreg.required': 'nickname,email'
    }

    assert_equal "You are requesting access to an account that's not yours. Please <a href='/logout'>log out</a> and use the correct account, or <a href='https://spectralworkbench.org/'>try to login with the correct username</a>", flash[:error]

    assert_response :redirect

  end

  test 'openid authentication request does not go to index page' do

    # log in
    post '/user_sessions', params: { user_session: { username: users(:jeff).username, password: 'secretive' } }
    follow_redirect!

    get '/openid', params: {
      'openid.claimed_id': "https://spectralworkbench.org/openid/#{users(:jeff).username}",
      'openid.identity': "https://spectralworkbench.org/openid/#{users(:jeff).username}",
      'openid.mode': 'checkid_setup',
      'openid.ns': 'http://specs.openid.net/auth/2.0',
      'openid.ns.sreg': 'http://openid.net/extensions/sreg/1.1',
      'openid.realm': 'https://spectralworkbench.org/',
      'openid.return_to': "https://spectralworkbench.org/session/new?authenticity_token=RcLcGH3lzSTCC24UpPnNm56sllNaMrHg5%2FSrQzNxB%2B4%3D&back_to=&open_id=#{users(:jeff).username}&return_to=",
      'openid.sreg.required': 'nickname,email'
    }

    assert_nil flash[:error]
    assert_response :found
    assert_routing({ path: path, method: :get }, { controller: 'openid', action: 'index' })

    ## now same with POST

    # More complete parameters:
    # {"authenticity_token"=>"RcLcGH3lzSTCC24UpPnNm56sllNaMrHg5/SrQzNxB+4=", "back_to"=>"/", "open_id"=>"warren", "openid.assoc_handle"=>"{HMAC-SHA1}{5b1d5a10}{bGMKfQ==}", "openid.claimed_id"=>"http://localhost:3000/openid/warren", "openid.identity"=>"http://localhost:3000/openid/warren", "openid.mode"=>"check_authentication", "openid.ns"=>"http://specs.openid.net/auth/2.0", "openid.ns.sreg"=>"http://openid.net/extensions/sreg/1.1", "openid.op_endpoint"=>"http://localhost:3000/openid", "openid.response_nonce"=>"2018-06-10T17:04:16ZSTb7YI", "openid.return_to"=>"http://localhost:3001/session/new?authenticity_token=RcLcGH3lzSTCC24UpPnNm56sllNaMrHg5%2FSrQzNxB%2B4%3D&back_to=%2F&open_id=warren&return_to=%2F", "openid.sig"=>"cElPJYRTb7IDCsZe3eLx639cchg=", "openid.signed"=>"assoc_handle,claimed_id,identity,mode,ns,ns.sreg,op_endpoint,response_nonce,return_to,signed,sreg.email,sreg.nickname", "openid.sreg.email"=>"jeff@unterbahn.com", "openid.sreg.nickname"=>"warren", "return_to"=>"/"}
    post '/openid?openid.claimed_id=' + users(:jeff).username, params: {
      'openid.claimed_id': "https://spectralworkbench.org/openid/#{users(:jeff).username}",
      'openid.identity': "https://spectralworkbench.org/openid/#{users(:jeff).username}",
      'openid.mode': 'checkid_setup',
      'openid.ns': 'http://specs.openid.net/auth/2.0',
      'openid.ns.sreg': 'http://openid.net/extensions/sreg/1.1',
      'openid.realm': 'https://spectralworkbench.org/',
      'openid.return_to': "https://spectralworkbench.org/session/new?authenticity_token=RcLcGH3lzSTCC24UpPnNm56sllNaMrHg5%2FSrQzNxB%2B4%3D&back_to=&open_id=#{users(:jeff).username}&return_to=",
      'openid.sreg.required': 'nickname,email'
    }

    assert_nil flash[:error]
    assert_response :found
    assert_routing({ path: path, method: :post }, { controller: 'openid', action: 'index' })

    # Then, 'openid authentication approval goes to decision page'  -- based on same session

    # log in
    post '/user_sessions', params: { user_session: { username: users(:jeff).username, password: 'secretive' } }
    follow_redirect!

    post '/openid/decision', params: {
      "authenticity_token": "RcLcGH3lzSTCC24UpPnNm56sllNaMrHg5%2FSrQzNxB%2B4%3D",
      "yes": "Yes"
    }

    # redirects back to originating site
    assert_match /https:\/\/spectralworkbench.org\/session\/new/, @response.redirect_url
  end

end
