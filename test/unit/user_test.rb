require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "user creation" do
    user =  FactoryGirl.create(:user)#, :username => "frank", :password => "secret")
    User.authenticate("warren", "secret").should == user
  end

end
