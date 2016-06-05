module API
  module Entities
    class SearchRequest < Grape::Entity
      expose :srchString, documentation: { type: "String", desc: "Search Query text."}
      expose :seq, documentation: { type: "Integer", desc: "Sequence value passed from client through to the SearchResult.  For client sequencing usage" }      
    end
  end
end
