class SearchCriteria
  attr_reader :query, :tag

  def initialize(query, tag = nil)
    @query = query
    @tag = tag
  end

  def valid?
    !query.nil? && query != 0
  end
end
