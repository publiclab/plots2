require 'grape'
require 'grape-swagger'
<<<<<<< c571a71720a7940582b99615557297ba75ee58ed
require 'grape-entity'
=======

require 'grape'
>>>>>>> Successful RESTful search call for typeahead

module Srch
  class API < Grape::API
    default_format :json

    # mount the individual api modules here
    # mount API::HighScores => '/high_scores'
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
