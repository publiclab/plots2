class SearchCriteria
  attr_reader :query, :tag, :order_by

  def initialize(query, tag: nil, order_by: nil, sort_direction: "DESC")
    @query = query
    @tag = tag
    @order_by = order_by
    @sort_direction = sort_direction
  end

  def valid?
    !query.nil? && query != 0
  end

  def sort_direction
    sanitize_direction(@sort_direction)
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
