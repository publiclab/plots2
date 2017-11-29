require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  test 'should not save answer without content' do
    answer = Answer.new
    assert !answer.save
  end

  test 'should save answer with a content' do
    answer = Answer.new(content: 'A test answer')
    assert answer.save
  end

  test 'should relate answer to user and node' do
    answer = Answer.new(content: 'a test answer')
    node = nodes(:question)
    user = drupal_users(:bob)
    answer.node = node
    answer.drupal_user = user
    answer.save
    assert_equal node.answers.last, answer
    assert_equal user.answers.last, answer
  end

  test 'should have node and author methods' do
    answer = answers(:one)
    node = nodes(:question)
    user = drupal_users(:bob)
    assert_equal answer.node, node
    assert_equal answer.author, user
  end

  test 'should return user objects who liked it' do
    answer = answers(:one)
    user = users(:bob)
    assert_equal answer.likers, [user]
  end

  test 'should assert users who liked it' do
    bob = drupal_users(:bob)
    jeff = drupal_users(:jeff)
    answer = answers(:one)
    assert answer.liked_by(bob.uid)
    assert !answer.liked_by(jeff.uid)
  end

  test 'should list comments in descending order' do
    answer = answers(:one)
    assert_equal answer.comments.last, Comment.last
  end
end
