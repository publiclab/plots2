require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Comment.new.valid?
  end

  test "should not save comment without body" do
    post = Post.new
    assert !post.save, "Saved the comment without body text"
  end

end
