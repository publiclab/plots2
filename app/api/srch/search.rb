require 'grape'
require 'grape-entity'

module Srch
  class Search < Grape::API
    # we are using a group of reusable parameters using a shared params helper
    # see /app/api/srch/shared_params.rb
    helpers SharedParams

    # Endpoint definitions
    resource :srch do
      # Request URL should be /api/srch/all?srchString=QRY
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of all available resources', hidden: false,
                                                          is_array: false,
                                                          nickname: 'srchGetAll'
      params do
        use :common
      end
      get :all do
        Search.execute(:all, params)
      end

      # Request URL should be /api/srch/profiles?srchString=QRY[&sort_by=recent&order_direction=desc&field=username]
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of profiles', hidden: false,
                                           is_array: false,
                                           nickname: 'srchGetProfiles'

      params do
        use :common, :sorting, :ordering, :field
      end
      get :profiles do
        Search.execute(:profiles, params)
      end

      # Request URL should be /api/srch/notes?srchString=QRY
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of research notes', hidden: false,
                                                 is_array: false,
                                                 nickname: 'srchGetNotes'

      params do
        use :common
      end
      get :notes do
        Search.execute(:notes, params)
      end

      # Request URL should be /api/srch/questions?srchString=QRY
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of questions tables', hidden: false,
                                                   is_array: false,
                                                   nickname: 'srchGetQuestions'

      params do
        use :common
      end
      get :questions do
        Search.execute(:questions, params)
      end

      # Request URL should be /api/srch/tags?srchString=QRY
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of documents associated with tags within the system', hidden: false,
                                                                                   is_array: false,
                                                                                   nickname: 'srchGetByTags'

      params do
        use :common
      end
      get :tags do
        Search.execute(:tags, params)
      end

      # Request URL should be /api/srch/taglocations?srchString=QRY[&tagName=awesome]
      # Note: Query(QRY as above) must have latitude and longitude as srchString=lat,lon
      desc 'Perform a search of documents having nearby latitude and longitude tag values', hidden: false,
                                                                                            is_array: false,
                                                                                            nickname: 'srchGetLocations'

      params do
        use :common, :additional
      end
      get :taglocations do
        Search.execute(:taglocations, params)
      end

      # API TO FETCH QRY RECENT CONTRIBUTORS
      # Request URL should be /api/srch/peoplelocations?srchString=QRY[&tagName=group:partsandcrafts]
      # QRY should be a number
      desc 'Perform a search to show x Recent People',  hidden: false,
                                                        is_array: false,
                                                        nickname: 'srchGetPeople'

      params do
        use :common, :additional
      end
      get :peoplelocations do
        Search.execute(:peoplelocations, params)
      end
    end

    def self.execute(endpoint, params)
      sresult = DocList.new
      search_type = endpoint
      search_criteria = SearchCriteria.new(params)

      if search_criteria.valid?
        sresult = ExecuteSearch.new.by(search_type, search_criteria)
      end

      sparms = SearchRequest.fromRequest(params)
      sresult.srchParams = sparms
      sresult
    end
  end
end
