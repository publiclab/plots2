require 'grape'

module API
  class Base < Grape::API
    default_format :json
  
    # mount the individual api modules here
    # mount API::HighScores => '/high_scores'

    # Add the swagger documentation
    add_swagger_documentation(
      base_path: "/api",
      hide_documentation_path: true
    )
  end
end
