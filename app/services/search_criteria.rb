class SearchCriteria
  include TextSearch
  attr_reader :query, :coordinates, :tag, :field, :limit
  attr_accessor :sort_by

  def initialize(args)
    @query = args[:query]
    unless @query.nil?
      @query = transform(@query)
    end
    @coordinates = { "nwlat" => args[:nwlat], "selat" => args[:selat], "nwlng" => args[:nwlng], "selng" => args[:selng] }
    @tag = args[:tag]
    @sort_by = args[:sort_by]
    @order_direction = args[:order_direction]
    @field = args[:field]
    @limit = args[:limit] || 10
  end

  def valid?
    (!query.nil? && query != 0) || !coordinates.nil?
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

  def transform(query)
    words = query.gsub(/\s+/m, ' ').strip.split(" ")
    words.map! { |item| lemmatize(item) }
    words.join(' ')
  end
end
