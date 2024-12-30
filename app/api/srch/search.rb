# Request URL should be /api/srch/taglocations?query=QRY[&tag=awesome]
desc 'Perform a search of documents having nearby latitude and longitude tag values', hidden: false,
                                                                                      is_array: false,
                                                                                      nickname: 'search_tag_locations'

params do
  use :geographical, :additional, :period, :sorting, :ordering
end
get :taglocations do
  search_request = SearchRequest.from_request(params)
  if params[:tagName] == 'question:*'
    # Handle the special case to fetch all results
    results = Search.execute(:taglocations, params, fetch_all: true)
  else
    results = Search.execute(:taglocations, params)
  end

  if results.present?
    docs = results.map do |model|
      # Mapping logic for the results
    end
    DocList.new(docs, search_request)
  else
    DocList.new('', search_request)
  end
end
