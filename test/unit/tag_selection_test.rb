require 'test_helper'

class TagSelectionTest < ActiveSupport::TestCase

  test 'graph' do
    Timecop.freeze # account for timestamp change
    end_time = Time.now
    start_time = end_time - 4.weeks
    ts_count = TagSelection.select(:following, :created_at)
      .where(following: true, created_at: (start_time..end_time))
      .count

    graph = TagSelection.graph(start_time, end_time)

    assert_equal ts_count, graph.values.sum
    assert_equal Hash, graph.class
    Timecop.return # unfreeze
  end
end
