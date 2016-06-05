module API
  module Entities
    # A DocResult is an individual return item for a document (web page) search
    class DocResult < Grape::Entity
      expose :docType
      expose :docUrl
      expose :docTitle
      expose :docSummary
      expose :docTags
      expose :docScore
    end
  end
end

      
