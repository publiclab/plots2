# Class encapsulating search requests.
class SearchRequest

  attr_accessor :srchString, :seq
      
  def initialize(sstring,seqno)
    @srchString = sstring
    @seq = seqno
  end
  
  # This subclass is used to auto-generate the RESTful data structure.  It is generally not useful for internal Ruby usage
  #  but must be included for full RESTful functionality.
  class Entity < Grape::Entity
    expose :srchString, documentation: { type: "String", desc: "Search Query text."}
    expose :seq, documentation: { type: "Integer", desc: "Sequence value passed from client through to the SearchResult.  For client sequencing usage" } 
  end   
end

