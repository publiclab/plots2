require 'grape'

module API
  class Base < Grape::API
    version 'v1', using: :header, vendor: 'publiclab'
    format :json
    prefix :api
  
    # mount the individual api modules here
    # mount API::HighScores => '/high_scores'
    mount API::Typeahead => '/'


    # Add the swagger documentation
    add_swagger_documentation(
      base_path: "/api",
      hide_documentation_path: true
    )
  end
end
