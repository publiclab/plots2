require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  test "should not save answer without content" do
    answer = Answer.new
    assert !answer.save
  end

  test "should save answer with a content" do
    answer = Answer.new(content: "A test answer")
    assert answer.save
  end

  test "should relate answer to user and node" do
    answer = Answer.new(content: "a test answer")
    node = node(:question)
    user = users(:bob)
    answer.drupal_node = node
    answer.drupal_users = user
    answer.save
    assert_equal node.answers.last, answer
    assert_equal user.answers.last, answer
  end

  test "should have node and author methods" do
    answer = answers(:one)
    node = node(:question)
    user = users(:bob)
    assert_equal answer.node, node
    assert_equal answer.author, user
  end
end
