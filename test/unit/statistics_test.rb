require 'test_helper'

class StatisticsTest < ActiveSupport::TestCase
  def setup
    @user = users(:bob)
  end

  test 'daily_note_tally returns the correct type of hash' do
    daily_notes = @user.daily_note_tally
    assert_not_empty daily_notes
    assert_equal daily_notes.count, 365
    assert_equal Hash, daily_notes.class
  end

  test 'weekly_note_tally returns the correct type of hash' do
    weekly_notes = @user.weekly_note_tally
    assert_not_nil weekly_notes
    assert_equal Hash, weekly_notes.class
    assert_equal (0..52).count, weekly_notes.count
  end

  test 'weekly_comment_tally' do
    weekly_comments = @user.weekly_comment_tally
    assert_not_nil weekly_comments
    assert_equal Hash, weekly_comments.class
    assert_equal (0..52).count, weekly_comments.count
  end

  test 'note_streak' do
    note_streak = @user.note_streak
    assert_not_nil note_streak.count
    assert_equal Array, note_streak.class
    assert_equal 2, note_streak.length
  end

  test 'wiki_edit streak' do
    wiki_streak =@user.wiki_edit_streak
    assert_not_nil wiki_streak
    assert_equal Array, wiki_streak.class
    assert_equal 2, wiki_streak.length
  end

  test 'comment_streak' do
    comment_streak = @user.comment_streak
    assert_not_nil comment_streak
    assert_equal Array, comment_streak.class
    assert_equal 2, comment_streak.length
  end

  test 'streak' do
    streak = @user.streak
    assert_equal Array, streak.class
    assert_equal 2, streak.length
    assert_equal 3, streak[1].length
  end
end
