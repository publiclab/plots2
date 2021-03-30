require 'test_helper'

class TagSelectionTest < ActiveSupport::TestCase

  test 'graph' do
    start_time = (Date.today - 1.month).to_time
    end_time = Date.today.to_time
    ts_count = TagSelection.select(:following, :created_at)
      .where(following: true, created_at: (start_time..end_time))
      .count

    graph = TagSelection.graph(start_time, end_time)

    assert_equal ts_count, graph.values.sum
    assert_equal Hash, graph.class
  end
end
