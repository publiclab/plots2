module QuestionsHelper
  SORTING_OPTIONS = %w(All Week Month Year).freeze

  def questions_stats(period)
    return if period.nil?

    if period == 'All'
      Rails.cache.fetch("all_stats", expires_in: 1.days) do
        @asked = Node.questions.length
        @answered = Answer.all.map(&:node).uniq.count
        "#{@asked} questions asked and #{@answered} questions answered"
      end
    else
      Rails.cache.fetch("#{period}_stats", expires_in: 1.days) do
        @asked = Node.questions.where('created >= ?', 1.send(period.downcase).ago.to_i).length
        @answered = Answer.where("created_at >= ?", 1.send(period.downcase).ago).map(&:node).uniq.count
        "#{@asked} questions asked and #{@answered} questions answered in the past #{period.downcase}"
      end
    end
  end

  def options
    SORTING_OPTIONS
  end
end
