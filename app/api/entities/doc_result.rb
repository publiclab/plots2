module API
  module Entities
    # A DocResult is an individual return item for a document (web page) search
    class DocResult < Grape::Entity
      expose :docType, documentation: { type: "String", desc: "Type of web document being returned." }
      expose :docUrl, documentation: { type: "String", desc: "URL to the resource document." }
      expose :docTitle, documentation: { type: "String", desc: "Title or primary descriptor of the linked result." }
      expose :docSummary, documentation: { type: "String", desc: "If available, first paragraph or descriptor of the linked document." }
      expose :docTags, using API::Entities::TagResult, as: :responses, documentation: { type: "API::Entities::TagResult", desc:  "An array of the associated tag values for the document, if they exist." }
      expose :docScore, documentation: { type: "Float", desc: "If calculated, the relevance of the document result to the search request; i.e. the 'matching score'" }
    end
  end
end

      
