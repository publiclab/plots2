require 'test_helper'

class RoutesTest < ActionDispatch::IntegrationTest

	test "test signup route" do
	  assert_routing({ path: '/signup', method: :get }, { controller: 'users', action: 'new' })
	end

	test "test user create route" do
	  assert_routing({ path: '/register', method: :post }, { controller: 'users', action: 'create' })
	end

	test "test people list route" do 
		 assert_routing({ path: '/people', method: :get }, { controller: 'users', action: 'list' })
	end
end
