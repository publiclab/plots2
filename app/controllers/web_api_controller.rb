# This controller provides UI access to investigate and
# browse the RESTful API endpoints using a Swagger UI
# and the automapping from the Swagger data at /api/swagger.json
#
# Swagger UI migrated from original repository at https://github.com/swagger-api/swagger-ui

class WebApiController < ApplicationController

  def index
    @title="Public Lab RESTful API Explorer"
  end
end