require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    activate_authlogic
  end

  test "user creation" do
    drupal_user = FactoryGirl.create(:drupal_users)
    user =  FactoryGirl.create(:user)#, :username => "frank", :password => "secret")
    UserSession.new(user)
    #User.authenticate("warren", "secret").should == user
  end

end
