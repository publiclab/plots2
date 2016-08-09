require 'test_helper'
require 'rest-client'
require 'json_expressions/rspec'

class SwaggerDocTest < ActionController::TestCase

  test 'Swagger doc functionality' do
    docresponse = RestClient.get 'http://localhost:3000/api/swagger_doc.json'
    
    # Expected swagger doc patter
    pattern = {
      basePath: "/api",
      swagger: "2.0",
      info: {
        title: String,
        description: String,
        version: String,
        contact: {
          name: String,
          email: String
        }
      },
      host: String
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)
    assert matcher =~ JSON.parse(docresponse.body)
  end

end

