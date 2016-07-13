require 'test_helper'
require 'rest-client'

class SwaggerDocTest < ActionController::TestCase

  test 'Swagger doc functionality' do
    docresponse = RestClient.get 'http://localhost:3000/api/swagger_doc.json'
    assert_equal docresponse.code, 200
    swaggerDoc = JSON.parse docresponse.body
    assert_not_nil swaggerDoc
    # basePath should always be '/api'
    assert swaggerDoc.basePath == '/api'
    #host name returned
    assert swaggerDoc.host.kind_of?(String)
    # api info should exist
    assert_not_nil swaggerDoc.info
    assert swaggerDoc.info.title.kind_of?(String)
    assert swaggerDoc.info.title.kind_of?(String)
    # contact info should exists
    assert_not_nil swaggerDoc.info.contact
    assert swaggerDoc.info.contact.kind_of?(Object)
    # various definitions should be supplied
    assert_not_nil swaggerDoc.definitions

  end


end

