require 'grape'

module Srch
  class Typeahead < Grape::API

    resource :typeahead do

      # Request URL should be /api/typeahead/all/:id
      # Basic implementation from classic plots2 SearchController
      get :all do
        match = SearchService.new.type_ahead(params[:id])
        { sresult: match }
      end

      get :test do
        { sresult: 'success!' }
      end
    end

  end
end
