require 'grape'

module Srch
  module SharedParams
    extend Grape::API::Helpers

    params :common do
      requires :srchString, type: String, documentation: { example: 'Spec' }
      optional :seq, type: Integer, documentation: { example: 995 }
      optional :showCount, type: Integer, documentation: { example: 3 }
      optional :pageNum, type: Integer, documentation: { example: 0 }
    end

    params :additional do
      optional :tagName, type: String, documentation: { example: 'awesome' }
    end
  end
end
