# A DocResult is an individual return item for a document (web page) search
class DocResult
  
  attr_accessor :docId, :docType, :docUrl, :docTitle, :docSummary, :docScore

  def initialize
  end

  def self.fromSearch(idval, typeval, urlval,titleval,sumval,scoreval)
    @docId = idval
    @doctype = typeval
    @docUrl = urlval
    @docTitle = titleval
    @docSummary = sumval
    @docScore = scoreval
  end

  # This subclass is used to auto-generate the RESTful data structure.  It is generally not useful for internal Ruby usage
  #  but must be included for full RESTful functionality.
  class Entity < Grape::Entity
      expose :docId, documentation: { type: "Integer", desc: "Not required, but Primary key of document."}
      expose :docType, documentation: { type: "String", desc: "Type of web document being returned." }
      expose :docUrl, documentation: { type: "String", desc: "URL to the resource document." }
      expose :docTitle, documentation: { type: "String", desc: "Title or primary descriptor of the linked result." }
      expose :docSummary, documentation: { type: "String", desc: "If available, first paragraph or descriptor of the linked document." }
      expose :docScore, documentation: { type: "Float", desc: "If calculated, the relevance of the document result to the search request; i.e. the 'matching score'" }
  end
end

