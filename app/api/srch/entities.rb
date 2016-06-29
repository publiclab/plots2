module Srch
  module Entities
    # Class encapsulating search requests.
    class SearchRequest < Grape::Entity
      def initialize
      end
      expose :srchString, documentation: { type: "String", desc: "Search Query text."}
      expose :seq, documentation: { type: "Integer", desc: "Sequence value passed from client through to the SearchResult.  For client sequencing usage" }      
    end

    # A DocResult is an individual return item for a document (web page) search
    class DocResult < Grape::Entity
      def initialize
      end
      expose :docId, documentation: { type: "Integer", desc: "Not required, but Primary key of document."}
      expose :docType, documentation: { type: "String", desc: "Type of web document being returned." }
      expose :docUrl, documentation: { type: "String", desc: "URL to the resource document." }
      expose :docTitle, documentation: { type: "String", desc: "Title or primary descriptor of the linked result." }
      expose :docSummary, documentation: { type: "String", desc: "If available, first paragraph or descriptor of the linked document." }
      expose :docScore, documentation: { type: "Float", desc: "If calculated, the relevance of the document result to the search request; i.e. the 'matching score'" }
    end

    # Tags are text values assigned to various site documents.
    class TagResult < Grape::Entity
      def initialize
      end
      expose :tagId, documentation: { type:  "Integer", desc: "Not required, but the primary key identifer for this tag" }
      expose :tagVal, documentation: { type: "String", desc: "The text value of the tag" }
      expose :tagType, documentation: { type: "String", desc:  "The type of tag this represents" }
      expose :tagSource, documentation: { type: "String", desc: "The original source of the tag value; this varies for different document types" }
    end

    # SearchResult encapsulates the values returned from a search request.
    class TagList < Grape::Entity
      def initialize
      end
      present_collection true
      expose :items, as: 'tags', using: Srch::Entities::TagResult
      expose :srchParams, using: Srch::Entities::SearchRequest   
    end

   class DocList < Grape::Entity
      def initialize
      end
      present_collection true
      expose :items, as: 'docs', using: Srch::Entities::DocResult
      expose :srchParams, using: Srch::Entities::SearchRequest   
    end

  end
end
