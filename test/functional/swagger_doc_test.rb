require 'test_helper'
require 'json_expressions/rspec'

class SwaggerDocTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

  test 'Swagger doc functionality' do
    get '/api/swagger_doc.json'
    assert last_response.ok?

    # Expected swagger doc patter
    pattern = {
      basePath: '/api',
      swagger: '2.0',
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
    assert matcher =~ JSON.parse(last_response.body)
  end
end
