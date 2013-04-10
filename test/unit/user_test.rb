require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    activate_authlogic
    @user =  FactoryGirl.create(:user)
    @drupal_user =  FactoryGirl.create(:drupal_users, :name => @user.username, :mail => @user.email)
  end

  def teardown
    @user.destroy
    @drupal_user.destroy
  end

  test "user creation" do
    UserSession.new(@user)
  end

end
