module Search
  class API < Grape::API
    version 'v1', using: :header, vendor: 'publiclab'
    format :json
    prefix :api

  resource :srch do
    desc 'Return tags that match the search text.'
    params do
      requires :req, type: API::Entities::SearchResult
    end
    get :tags do
      # Perfom search tags.
    end

end
