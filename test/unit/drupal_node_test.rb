require 'test_helper'

class DrupalNodeTest < ActiveSupport::TestCase

  # test "the truth" do
  #   assert true
  # end

  test "should not save node without title, or anything else" do
    node = DrupalNode.new
    assert !node.save
  end

end
