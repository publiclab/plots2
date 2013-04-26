require 'test_helper'

class DrupalNodeTest < ActiveSupport::TestCase

  def setup
    activate_authlogic
    @user =  FactoryGirl.create(:user)
  end

  def teardown
    @user.destroy
  end

  test "create a node" do
    node =  FactoryGirl.create(:drupal_node, :uid => @user.uid)
    node_revision = FactoryGirl.create(:drupal_node_revision, :nid => node.id)
    assert node.save!
  end

  #test "should not save node without title, or anything else" do
    #node = DrupalNode.new
    #assert !node.save
  #end

end
