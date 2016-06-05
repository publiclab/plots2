module API
  module Entities
    # Tags are text values assigned to various site documents.
    class TagResult < Grape::Entity
      expose :tagId
      expose :tagVal
      expose :tagType
    end
  end
end
