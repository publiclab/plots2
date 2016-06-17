require 'grape'
require 'grape-swagger'
require 'grape-entity'

module Srch
  class API < Grape::API
    default_format :json
    format :json
  
    # mount the individual api modules here
    mount Srch::Typeahead


    # Add the swagger documentation
    add_swagger_documentation :format => :json,
                              :api_version => 'v1',
                              :hide_documentation_path => true,
                              :mount_path => '/swagger_doc',
                              models: [
                                  Srch::Entities::SearchRequest,
                                  Srch::Entities::DocResult,
                                  Srch::Entities::TagResult,
                                  Srch::Entities::SearchResult
                              ]

  end
end
