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
    mount Srch::Search

    # Add the swagger documentation
    add_swagger_documentation :format => :json,
      :api_version => 'v1',
      :hide_documentation_path => true,
      :mount_path => '/swagger_doc',
      models: [
        SearchRequest::Entity,
        DocResult::Entity,
        TagResult::Entity,
        DocList::Entity,
        TagList::Entity
      ],
      info: {
        title: "RESTful API calls for Public Lab site",
        description: "These API calls provide programmatic access to features and data resources within Public Lab",
        contact_name: "Public Lab Web Working Group",
        contact_email: "web@publiclab.org",
        version: "1.0.0"
      }
  end

end
