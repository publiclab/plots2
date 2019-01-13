require 'grape'

module Srch
  module SharedParams
    extend Grape::API::Helpers

    params :common do
      requires :query, type: String, documentation: { example: 'Spec' }
      optional :limit, type: Integer, documentation: { example: 10 }
    end

    params :geographical do
      requires :nwlat, type: Float, documentation: { example: 10.2 }
      requires :selat, type: Float, documentation: { example: 10.2 }
      requires :nwlng, type: Float, documentation: { example: 10.2 }
      requires :selng, type: Float, documentation: { example: 10.2 }
    end

    params :additional do
      optional :tag, type: String, documentation: { example: 'awesome' }
    end

    params :ordering do
      optional :order_direction, type: String, documentation: { example: 'DESC' }
    end

    params :sorting do
      optional :sort_by, type: String, documentation: { example: 'recent' }
    end

    params :field do
      optional :field, type: String, documentation: { example: 'username' }
    end
  end
end
