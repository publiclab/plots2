class SearchCriteria
  attr_reader :query, :tag, :sort_by, :field, :limit

  def initialize(params)
    @query = params[:srchString]
    @tag = params[:tagName]
    @sort_by = params[:sort_by]
    @order_direction = params[:order_direction]
    @field = params[:field]
    @limit = params[:limit]
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
