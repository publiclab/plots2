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

    test "test get request for answer update" do
        assert_routing({ path: '/answers/update/1', method: 'get' }, { controller: 'answers', action: 'update', id: '1' })
    end

    test "test get request for answer accept" do
        assert_routing({ path: '/answers/accept/1', method: 'get' }, {controller: 'answers', action: 'accept', id: '1' })
    end

    test "test get request for promote comment to answer" do
        assert_routing({ path: '/comment/make_answer/1', method: 'get' }, {controller: 'comment', action: 'make_answer', id: '1' })
    end

    test "test get request for deleting an answer" do
        assert_routing({ path: '/answers/delete/:id', method: 'get' }, {controller: 'answers', action: 'delete', id: ':id' })
    end

    test "test get request for updating a comment" do
        assert_routing({ path: '/comment/update/:id', method: 'get' }, {controller: 'comment', action: 'update', id: ':id' })
    end
    
    test "test post request for updating an answer" do
    	assert_routing({path: '/answers/update/1', method: 'post' }, {controller: 'answers', action: 'update', id: '1' })
    end

    test "test get request for liking an answer" do
        assert_routing({path: 'questions/:username/:date/:topic/answer_like/likes/:aid', method: 'get'}, {controller: 'answer_like', action: 'likes', username: ":username", date: ":date", topic: ":topic", aid: ":aid"})
    end
	
end
