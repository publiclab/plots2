require 'test_helper'

class TagSelectionTest < ActiveSupport::TestCase

  test 'graph' do
    ts_count = TagSelection.select(:following, :created_at)
      .where(following: true, created_at: (Time.now - 1.year..Time.now))
      .count

    graph = TagSelection.graph(Time.now - 1.year, Time.now)

    assert_equal ts_count, graph.values.sum
    assert_equal Hash, graph.class
  end
end
