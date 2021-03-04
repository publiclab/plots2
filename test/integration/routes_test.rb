require 'test_helper'

class RoutesTest < ActionDispatch::IntegrationTest

	def setup
      activate_authlogic
   	end

	test "test signup route" do
	    assert_routing({ path: '/signup', method: :get }, { controller: 'users', action: 'new' })
	end

	test "test user create route" do
	    assert_routing({ path: '/register', method: :post }, { controller: 'users', action: 'create' })
	end

	test "test people list route" do 
		assert_routing({ path: '/people', method: :get }, { controller: 'users', action: 'list' })
	end

	test "test profile page route" do 
		assert_routing({ path: '/profile/jeff', method: :get }, { controller: 'users', action: 'profile' , id: 'jeff' })
	end

	test "test places route" do
	    assert_routing({ path: '/places', method: :get }, { controller: 'notes', action: 'places' })
	end

	test "edit profile route when user logged out redirects to profile page" do	
    	assert_routing({ path: '/profile/jeff/edit', method: :get }, { controller: 'users', action: 'edit' , id: 'jeff' })	
        get '/profile/jeff/edit'
        assert_response 302 	#error code 302 is for REDIRECT : https://stackoverflow.com/questions/23788331/http-error-code-302-when-calling-https-webservice
        follow_redirect!
        assert_equal '/login' , path
	end

	test "edit profile route when user logged in " do
		UserSession.create(users(:jeff)) 	
    	assert_routing({ path: '/profile/jeff/edit', method: :get }, { controller: 'users', action: 'edit' , id: 'jeff' })	
        get '/profile/jeff/edit'	
        assert_equal '/profile/jeff/edit' , path
	end

  test "test get request for comment create" do
    assert_routing({ path: '/comment/create/8', method: :get }, { controller: 'comment', action: 'create', id: '8' })
  end

  test "test get request for updating a comment" do
    assert_routing({ path: '/comment/update/:id', method: 'get' }, {controller: 'comment', action: 'update', id: ':id' })
  end
	
end
