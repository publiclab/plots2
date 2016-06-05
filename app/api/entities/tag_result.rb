module API
  module Entities
    # Tags are text values assigned to various site documents.
    class TagResult < Grape::Entity
      expose :tagId, documentation: { type:  "Integer", desc: "Not required, but the primary key identifer for this tag" }
      expose :tagVal, documentation: { type: "String", desc: "The text value of the tag" }
      expose :tagType, documentation: { type: "String", desc:  "The type of tag this represents" }
      expose :tagSource, documentation: { type: "String", desc: "The original source of the tag value; this varies for different document types" }
    end
  end
end
