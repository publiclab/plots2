module QuestionsHelper
  SORTING_OPTIONS = %w(All Week Month Year).freeze

  def filtering(period)
    return if period.nil?

    if period == 'All'
      @asked = Node.questions.to_a.size
      @answered = Answer.all.map(&:node).uniq.size
      "#{@asked} questions asked and #{@answered} questions answered"
    else
      @asked = Node.questions.where('created >= ?', 1.send(period.downcase).ago.to_i).to_a.size
      @answered = Answer.where("created_at >= ?", 1.send(period.downcase).ago).map(&:node).uniq.size
      "#{@asked} questions asked and #{@answered} questions answered in the past #{period}"
    end
  end

  def options
    SORTING_OPTIONS
  end
end
