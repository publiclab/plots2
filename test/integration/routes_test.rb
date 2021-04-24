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

	test "test archive route" do
	    assert_routing({ path: '/archive', method: :get }, { controller: 'map', action: 'index' })
	end

	test "test images route" do
	    assert_routing({ path: '/images', method: :get }, { controller: 'images', action: 'index' })
	end

	test "test features route" do
	    assert_routing({ path: '/features', method: :get }, { controller: 'features', action: 'index' })
	end

	test "test subscriptions route" do
	    assert_routing({ path: '/subscriptions', method: :get }, { controller: 'subscription', action: 'index' })
	end

	test "test methods route" do
	    assert_routing({ path: '/methods', method: :get }, { controller: 'wiki', action: 'methods' })
	end

	test "test blog2 route" do
	    assert_routing({ path: '/blog2', method: :get }, { controller: 'tag', action: 'blog2', id: 'blog' })
	end

	test "test notes route" do
	    assert_routing({ path: '/notes', method: :get }, { controller: 'notes', action: 'index' })
	end

	test "test wiki route" do
	    assert_routing({ path: '/wiki', method: :get }, { controller: 'wiki', action: 'index' })
	end

	test "test tags route" do
	    assert_routing({ path: '/tags', method: :get }, { controller: 'tag', action: 'index' })
	end

	test "test user tags route" do
	    assert_routing({ path: '/user_tags', method: :get }, { controller: 'user_tags', action: 'index' })
	end

	test "test stats route" do
	    assert_routing({ path: '/stats', method: :get }, { controller: 'stats', action: 'index' })
	end

	test "test user list route" do
	    assert_routing({ path: '/people', method: :get }, { controller: 'users', action: 'list' })
	end

	test "test likes route" do
	    assert_routing({ path: '/likes', method: :get }, { controller: 'like', action: 'index' })
	end

	test "test comments route" do
	    assert_routing({ path: '/comments', method: :get }, { controller: 'comment', action: 'index' })
	end

	test "test questions shadow route" do
	    assert_routing({ path: '/questions_shadow', method: :get }, { controller: 'questions', action: 'index_shadow' })
	end

	test "test wiki create route" do
	    assert_routing({ path: '/wiki/create', method: :post }, { controller: 'wiki', action: 'create' })
	end

	test "test notes create route" do
	    assert_routing({ path: '/notes/create', method: :post }, { controller: 'notes', action: 'create' })
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
