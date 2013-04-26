require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    activate_authlogic
    @user =  FactoryGirl.create(:user)
  end

  def teardown
    @user.destroy
  end

  test "user creation" do
    UserSession.new(@user)
  end

end
