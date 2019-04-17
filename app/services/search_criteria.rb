class SearchCriteria
  include TextSearch
  attr_reader :query, :coordinates, :tag, :field, :period, :limit
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
    @period = { "from" => args[:from], "to" => args[:to] }
    @limit = args[:limit] || 5 # to avoid navbar search showing only one type
  end

  def valid?
    (!query.nil? && query != 0) || !coordinates.nil?
  end

  def order_direction
    sanitize_direction(@order_direction)
  end

  def validate_period_from_to
    validate_period(@period)
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
    added_results = []
    words.each do |word|
      if word.include? "-"
        added_results << (word.delete '-')
      end
      hyphenated_word = results_with_probable_hyphens(word)
      if hyphenated_word != word
        added_results << hyphenated_word
      end
    end
    words += added_results
    words.join(' ')
  end

  def validate_period(period)
    if !period["from"].nil? && (period["from"] > Time.now)
      period["from"] = Time.now
    end
    if !period["to"].nil? && (period["to"] > Time.now)
      period["to"] = Time.now
    end
    if (!period["from"].nil? && !period["to"].nil?) && (period["from"] > period["to"])
      period["from"], period["to"] = period["to"], period["from"]
    end
  end
end
