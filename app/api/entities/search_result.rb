module API
  module Entities
    # SearchResult encapsulates the values returned from a search request.
    class SearchResult < Grape::Entity
      expose :docList
      expose :srchString
      
    end
  end
end

