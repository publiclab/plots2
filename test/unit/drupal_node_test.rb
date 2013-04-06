require 'test_helper'

class DrupalNodeTest < ActiveSupport::TestCase

  test "create a node" do
    node =  FactoryGirl.create(:drupal_node)
    #node_revision = FactoryGirl.create(:drupal_node_revision)
    #assert node.save!
  end

  #test "should not save node without title, or anything else" do
    #node = DrupalNode.new
    #assert !node.save
  #end

end
