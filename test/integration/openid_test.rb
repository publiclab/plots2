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

  test 'openid authentication request goes to index page' do

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
    assert_equal 'The site shown below is asking to use your PublicLab.org account to log you in. Do you trust this site?', flash[:notice]

    assert_response :success
    assert_routing({ path: path, method: :get }, { controller: 'openid', action: 'index' })

    ## now same with POST

    # More complete parameters:
    # {"authenticity_token"=>"RcLcGH3lzSTCC24UpPnNm56sllNaMrHg5/SrQzNxB+4=", "back_to"=>"/", "open_id"=>"warren", "openid.assoc_handle"=>"{HMAC-SHA1}{5b1d5a10}{bGMKfQ==}", "openid.claimed_id"=>"http://localhost:3000/openid/warren", "openid.identity"=>"http://localhost:3000/openid/warren", "openid.mode"=>"check_authentication", "openid.ns"=>"http://specs.openid.net/auth/2.0", "openid.ns.sreg"=>"http://openid.net/extensions/sreg/1.1", "openid.op_endpoint"=>"http://localhost:3000/openid", "openid.response_nonce"=>"2018-06-10T17:04:16ZSTb7YI", "openid.return_to"=>"http://localhost:3001/session/new?authenticity_token=RcLcGH3lzSTCC24UpPnNm56sllNaMrHg5%2FSrQzNxB%2B4%3D&back_to=%2F&open_id=warren&return_to=%2F", "openid.sig"=>"cElPJYRTb7IDCsZe3eLx639cchg=", "openid.signed"=>"assoc_handle,claimed_id,identity,mode,ns,ns.sreg,op_endpoint,response_nonce,return_to,signed,sreg.email,sreg.nickname", "openid.sreg.email"=>"jeff@unterbahn.com", "openid.sreg.nickname"=>"warren", "return_to"=>"/"}
    post '/openid', params: { 
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
    assert_equal 'The site shown below is asking to use your PublicLab.org account to log you in. Do you trust this site?', flash[:notice]

    assert_response :success
    assert_routing({ path: path, method: :post }, { controller: 'openid', action: 'index' })

    # Then, 'openid authentication approval goes to decision page'  -- based on same session

    # log in
    post '/user_sessions', params: { user_session: { username: users(:jeff).username, password: 'secretive' } } 
    follow_redirect!

    post '/openid/decision', params: { 
      "authenticity_token": "KfpoKpR20/cbyQ/Rw2YCa1pDlNeFNM0AsZ6PwSkOudRu3QBvviywgVf2qooiOMb0At5DPiqteW5BMjEwe5scJQ==",
      "yes": "Yes"
    }

    assert_redirected_to "http://localhost:3001/session/new?authenticity_token=RcLcGH3lzSTCC24UpPnNm56sllNaMrHg5%2FSrQzNxB%2B4%3D&back_to=%2F&open_id=warren&return_to=%2F&openid.assoc_handle=%7BHMAC-SHA1%7D%7B5b1d5a10%7D%7BbGMKfQ%3D%3D%7D&openid.claimed_id=http%3A%2F%2Flocalhost%3A3000%2Fopenid%2Fwarren&openid.identity=http%3A%2F%2Flocalhost%3A3000%2Fopenid%2Fwarren&openid.mode=id_res&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.ns.sreg=http%3A%2F%2Fopenid.net%2Fextensions%2Fsreg%2F1.1&openid.op_endpoint=http%3A%2F%2Flocalhost%3A3000%2Fopenid&openid.response_nonce=2018-06-10T17%3A04%3A16ZSTb7YI&openid.return_to=http%3A%2F%2Flocalhost%3A3001%2Fsession%2Fnew%3Fauthenticity_token%3DRcLcGH3lzSTCC24UpPnNm56sllNaMrHg5%252FSrQzNxB%252B4%253D%26back_to%3D%252F%26open_id%3Dwarren%26return_to%3D%252F&openid.sig=cElPJYRTb7IDCsZe3eLx639cchg%3D&openid.signed=assoc_handle%2Cclaimed_id%2Cidentity%2Cmode%2Cns%2Cns.sreg%2Cop_endpoint%2Cresponse_nonce%2Creturn_to%2Csigned%2Csreg.email%2Csreg.nickname&openid.sreg.email=jeff%40unterbahn.com&openid.sreg.nickname=warren"

  end

end
