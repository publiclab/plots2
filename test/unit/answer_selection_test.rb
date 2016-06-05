require 'test_helper'

class AnswerSelectionTest < ActiveSupport::TestCase
  test "should create answer_selection" do 
    answer_selection = AnswerSelection.new
    assert answer_selection.save
  end

  test "should relate answer_selection with answer and node" do
    answer_selection = AnswerSelection.new
    user = users(:bob)
    answer = answers(:one)
    answer_selection.drupal_users = user
    answer_selection.answer = answer
    answer_selection.save
    assert_equal user.answer_selections.last, answer_selection
    assert_equal answer.answer_selections.last, answer_selection
  end

  test "should have user method" do
    answer_selection = answer_selections(:one)
    user = rusers(:bob)
    assert_equal answer_selection.user, user
  end
end
