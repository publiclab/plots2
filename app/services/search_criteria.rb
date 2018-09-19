class SearchCriteria
  attr_reader :query, :tag, :field, :limit
  attr_accessor :sort_by

  def initialize(args)
    @query = args[:query]
    @tag = args[:tag]
    @sort_by = args[:sort_by]
    @order_direction = args[:order_direction]
    @field = args[:field]
    @limit = args[:limit] || 10
  end

  def self.from_params(params)
    args = {
      query: params[:srchString],
      tag: params[:tagName],
      sort_by: params[:sort_by],
      field: params[:field],
      limit: params[:limit]
    }
    new(args)
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
