class SearchCriteria
  attr_reader :query, :tag, :order

  def initialize(query, tag = nil, order = nil)
    @query = query
    @tag = tag
    @order = order
  end

  def valid?
    !query.nil? && query != 0
  end
end
