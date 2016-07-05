#List of documents returned from a search
class DocList

  attr_accessor :items, :srchParams, :pageNum, :pageCount

  def initialize
  end

  def addDoc ndoc
    @items ||= []
    @items << ndoc
  end

  def addAll dlist
    @items ||= []
    dlist.each { |docItem| @items << docItem} unless dlist.nil?
  end

  def getDocs
    @items
  end

  # This subclass is used to auto-generate the RESTful data structure.  It is generally not useful for internal Ruby usage
  #  but must be included for full RESTful functionality.
  class Entity < Grape::Entity
      expose :items, using: DocResult::Entity
      expose :srchParams, using: SearchRequest::Entity 
      expose :pageNum, documentation: { type: "Integer", desc: "Which page (zero-based counting, as in Array indexes) this return contains for paginated data."}
      expose :pageCount, documentation: { type: "Integer", desc: "Number of pages in paginated data that are the result of the search." }
  end
end

