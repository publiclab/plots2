require 'test_helper'

class DrupalNodeTest < ActiveSupport::TestCase

  def setup
    activate_authlogic
  end

  test "create a node" do
    drupal_user = FactoryGirl.create(:drupal_users, :uid => 2, :name => "frank", :mail => "frank@pxlshp.com") # currently dependent on drupal users, though we should drop that
    user =  FactoryGirl.create(:user, :username => drupal_user.name, :email => drupal_user.mail)

    node =  FactoryGirl.create(:drupal_node, :uid => user.uid)
    node_revision = FactoryGirl.create(:drupal_node_revision)
    #assert node.save!
  end

  #test "should not save node without title, or anything else" do
    #node = DrupalNode.new
    #assert !node.save
  #end

end
