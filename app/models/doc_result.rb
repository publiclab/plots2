# A DocResult is an individual return item for a document (web page) search
class DocResult
  attr_accessor :doc_id, :doc_type, :doc_url, :doc_title, :doc_score, :latitude, :longitude, :blurred, :category, :doc_author, :doc_image_url, :place_name, :created_at, :comment_count, :time_since, :user_photo_path

  def initialize(args = {})
    @doc_id = args[:doc_id]
    @doc_type = args[:doc_type]
    @doc_url = args[:doc_url]
    @doc_title = args[:doc_title]
    @doc_score = args[:doc_score]
    @doc_author = args[:doc_author]
    @doc_image_url = args[:doc_image_url]
    @latitude = args[:latitude]
    @longitude = args[:longitude]
    @blurred = args[:blurred]
    @category = args[:doc_type]
    @place_name = args[:place_name]
    @created_at = args[:created_at]
    @time_since = args[:time_since]
    @comment_count = args[:comment_count]
  end

  # This subclass is used to auto-generate the RESTful data structure.  It is generally not useful for internal Ruby usage
  #  but must be included for full RESTful functionality.
  class Entity < Grape::Entity
    expose :doc_id, documentation: { type: 'Integer', desc: 'Not required, but Primary key of document.' }
    expose :doc_type, documentation: { type: 'String', desc: 'Type of web document being returned.' }
    expose :doc_url, documentation: { type: 'String', desc: 'URL to the resource document.' }
    expose :doc_title, documentation: { type: 'String', desc: 'Title or primary descriptor of the linked result.' }
    expose :doc_score, documentation: { type: 'Float', desc: "If calculated, the relevance of the document result to the search request; i.e. the 'matching score'" }
    expose :latitude, documentation: { type: 'String', desc: "Returns the latitude associated with the node." }
    expose :longitude, documentation: { type: 'String', desc: "Returns the longitude associated with the node." }
    expose :place_name, documentation: { type: 'String', desc: "Returns the place name of the location associated with the node." }
    expose :created_at, documentation: { type: 'String', desc: "Returns the date the node was created." }
    expose :time_since, documentation: { type: 'String', desc: "Returns a description of the amount of time that has passed since the node was created." }
    expose :comment_count, documentation: { type: 'String', desc: "Returns the number of comments the user can view belonging to the node." }
  end
end
