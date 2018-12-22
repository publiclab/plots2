require 'test_helper'

class QuestionsHelperTest < ActionView::TestCase
  test 'should return null if period is nil' do
    assert_nil questions_stats(nil)
  end

  test 'should return all questions if all' do
    request = questions_stats("All")
    asked = Node.questions.length
    answered = Answer.all.map(&:node).uniq.count
    assert_not_nil request
    assert_includes request, asked.to_s
    assert_includes request, answered.to_s
  end

  test "should return exact count according to period given" do
    options.reject { |option| option == "All" }.each do |period|
      request = questions_stats(period)
      asked = Node.questions.where('created >= ?', 1.send(period.downcase).ago.to_i).length
      answered = Answer.where("created_at >= ?", 1.send(period.downcase).ago).map(&:node).uniq.count
      assert_includes request, asked.to_s
      assert_includes request, answered.to_s
    end
  end

  test 'it caches results' do
  end
end
