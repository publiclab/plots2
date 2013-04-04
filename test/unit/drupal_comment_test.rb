require 'test_helper'

class DrupalCommentTest < ActiveSupport::TestCase

  test 'new_comment_should_be_valid' do
    assert DrupalComment.new.valid?
  end

  #test "should not save comment without body" do
  #  note = DrupalNode.new
  #  assert !note.save, "Saved the comment without body text"
  #end

end
