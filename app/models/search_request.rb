# Class encapsulating search requests.
class SearchRequest

  # Minimum query length, or we return an empty result
  MIN_QUERY_LENGTH = 3
    
  attr_accessor :srchString, :seq, :showCount, :pageNum
      
  def initialize
  end

  def self.fromRequest(rparams)
    obj = new
    obj.srchString = rparams[:srchString]
    obj.seq = rparams[:seq]
    obj.showCount = rparams[:showCount]
    obj.pageNum = rparams[:pageNum]
    obj
  end

  # Check the query string to make sure it is not blank (null, empty string, or ' ')
  # and make sure it is at least 3 characters
  def valid? 
    isValid = true
    isValid = isValid && !srchString.blank?
    isValid = isValid && srchString.length >= MIN_QUERY_LENGTH 
    return isValid
  end

  
  # This subclass is used to auto-generate the RESTful data structure.  It is generally not useful for internal Ruby usage
  #  but must be included for full RESTful functionality.
  class Entity < Grape::Entity
    expose :srchString, documentation: { type: "String", desc: "Search Query text."}
    expose :seq, documentation: { type: "Integer", desc: "Sequence value passed from client through to the SearchResult.  For client sequencing usage" } 
    expose :showCount, documentation: { type: "Integer", desc: "The requested number of records to show per page" }
    expose :pageNum, documentation: { type: "Integer", desc: "Which page (zero-based counting, as in Array indexes) to show paginated data."}
  end   

end

