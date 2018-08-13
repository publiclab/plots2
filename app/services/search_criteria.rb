class SearchCriteria
  attr_reader :query, :tag, :sort_by

  def initialize(query, tag: nil, sort_by: nil, order_direction: "DESC")
    @query = query
    @tag = tag
    @sort_by = sort_by
    @order_direction = order_direction
  end

  def valid?
    !query.nil? && query != 0
  end

  def order_direction
    sanitize_direction(@order_direction)
  end

  private

  def sanitize_direction(direction)
    if direction.present?
      direction = direction.upcase
      options = %w(DESC ASC)
      options.include?(direction) ? direction : "DESC"
    else
      "DESC"
    end
  end
end
