#List of documents returned from a search
class DocList

  attr_accessor :items, :srchParams

  def initialize
  end

  def addDoc ndoc
    @items ||= []
    @items << ndoc
  end

  def getDocs
    @items
  end

  # This subclass is used to auto-generate the RESTful data structure.  It is generally not useful for internal Ruby usage
  #  but must be included for full RESTful functionality.
  class Entity < Grape::Entity
      expose :items, as: 'docs', using: DocResult::Entity
      expose :srchParams, using: SearchRequest::Entity 
  end
end

