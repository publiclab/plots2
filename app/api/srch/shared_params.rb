require 'grape'

module Srch
  module SharedParams
    extend Grape::API::Helpers

    params :common do
      requires :srchString, type: String, documentation: { example: 'Spec' }
    end

    params :additional do
      optional :tagName, type: String, documentation: { example: 'awesome' }
    end

    params :ordering do
      optional :order_direction, type: String, documentation: { example: 'desc' }
    end

    params :sorting do
      optional :sort_by, type: String, documentation: { example: 'recent' }
    end

    params :field do
      optional :field, type: String, documentation: { example: 'username' }
      optional :limit, type: Integer, documentation: { example: 0 }
    end
  end
end
