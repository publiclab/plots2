# List of tag values from a search
class TagList

  attr_accessor :items, :srchParams

  def initialize
  end   

  def setSrchParams=(value)
    @srchParams = value
  end

  def addTag ntag 
    @items ||= []
    @items << ntag
  end

  def getTags
    @items
  end

  # This subclass is used to auto-generate the RESTful data structure.  It is generally not useful for internal Ruby usage
  #  but must be included for full RESTful functionality.
  class Entity < Grape::Entity
      expose :items, as: 'tags', using: TagResult::Entity
      expose :srchParams, using: SearchRequest::Entity  
  end
end

