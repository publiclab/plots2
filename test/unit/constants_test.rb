require 'test_helper'

class ConstantsTest < ActiveSupport::TestCase
  # This is used to test the constants at config/initializer
  test "should not match backtick" do
    string = "@StlMaris123 @StlMaris123 `@StlMaris123`"
    expect = "REPLACE REPLACE `@StlMaris123`"
    assert_equal expect, string.gsub(Callouts.const_get(:FINDER), " REPLACE").lstrip!
  end
end
