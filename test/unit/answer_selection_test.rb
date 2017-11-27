require 'test_helper'

class AnswerSelectionTest < ActiveSupport::TestCase
  test 'should create answer_selection' do
    answer_selection = AnswerSelection.new
    assert answer_selection.save
  end

  test 'should relate answer_selection with answer and node' do
    answer_selection = AnswerSelection.new
    user = drupal_users(:bob)
    answer = answers(:one)
    answer_selection.drupal_user = user
    answer_selection.answer = answer
    answer_selection.save
    assert_equal user.answer_selections.last, answer_selection
    assert_equal answer.answer_selections.last, answer_selection
  end

  test 'should have user method' do
    answer_selection = answer_selections(:one)
    user = users(:bob)
    assert_equal answer_selection.user, user
  end

  test 'should create answer_selection if not present' do
    user = drupal_users(:admin)
    answer = answers(:one)
    assert_difference 'AnswerSelection.count' do
      assert AnswerSelection.set_likes(user.uid, answer.id, true)
    end
  end

  test 'should set liking false if value is false' do
    user = drupal_users(:bob)
    answer = answers(:one)
    assert_no_difference 'AnswerSelection.count' do
      assert !AnswerSelection.set_likes(user.uid, answer.id, false)
    end
  end

  test 'should not create new answer_selection if present' do
    user = drupal_users(:jeff)
    answer = answers(:one)
    assert_no_difference 'AnswerSelection.count' do
      assert AnswerSelection.set_likes(user.uid, answer.id, true)
    end
  end

  test 'should increase cached likes if liked' do
    user = drupal_users(:admin)
    answer = answers(:one)
    assert_difference 'answer.cached_likes' do
      AnswerSelection.set_likes(user.uid, answer.id, true)
      answer.reload
    end
  end

  test 'should decrease cached likes if unliked' do
    user = drupal_users(:bob)
    answer = answers(:one)
    assert_difference 'answer.cached_likes', -1 do
      AnswerSelection.set_likes(user.uid, answer.id, false)
      answer.reload
    end
  end
end
