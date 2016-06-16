require 'grape'
require 'grape-swagger'

require 'grape'

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
                              :mount_path => '/swagger_doc'

  end
end
