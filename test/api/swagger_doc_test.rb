require 'test_helper'
require 'rest-client'
require 'json_expressions'

class SwaggerDocTest < ActionController::TestCase

  test 'Swagger doc functionality' do
    docresponse = RestClient.get "http://localhost:3000/api/swagger_doc.json"
    assert_equal docresponse.code, 200
    docpattern = {
      basePath: "/api",
      host: String,
      info: {
        title: String,
        version: String,
        contact: {
          name: String,
          email: String,
        }
      },
      definitions: WILDCARD_MATCHER,
      paths: WILDCARD_MATCHER,
      produces: WILDCARD_MATCHER,
      swagger: String,
      tags:  [
        {
          name: String,
          description: String
        }
      ]
    }.ignore_extra_keys!
    
    assert_json_match(docpattern, docresponse.body)
    
  end


end

