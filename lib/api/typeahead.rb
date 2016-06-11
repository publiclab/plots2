module API
  class Typeahead < Grape::API
    
    desc 'RESTful method for typeahead for tag searches' do
      detail 'This method conducts searches for tags that match the given value.'
      params API::Entities::SearchRequest
      success API::Entities::SearchResult
    end
    get :tags do

    end

  end
end
