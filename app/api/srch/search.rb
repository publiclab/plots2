require 'grape'
require 'grape-entity'

module Srch
  class Search < Grape::API
    def self.create(endpoint)
      get endpoint.to_sym do
        sresult = DocList.new
        unless params[:srchString].nil? || params[:srchString] == 0
          sservice = SearchService.new
          if endpoint == "all"
            sresult = sservice.textSearch_all(params[:srchString])
          elsif endpoint == "profiles"
            sresult = sservice.textSearch_profiles(params[:srchString])
          elsif endpoint == "notes"
            sresult = sservice.textSearch_notes(params[:srchString])
          elsif endpoint == "questions"
            sresult = sservice.textSearch_questions(params[:srchString])
          elsif endpoint == "tags"
            sresult = sservice.textSearch_tags(params[:srchString])
          elsif endpoint == "peoplelocations"
            sresult = sservice.recentPeople(params[:srchString])
          elsif endpoint == "taglocations" && (params[:srchString].include? ",")
            sresult = sservice.tagNearbyNodes(params[:srchString], params[:tagName])
          end
        end
        sparms = SearchRequest.fromRequest(params)
        sresult.srchParams = sparms
        sresult
      end
    end

    # Endpoint definitions
    resource :srch do
      # add a default set of params
      helpers do
        params :common do
          requires :srchString, type: String, documentation: { example: 'Spec' }
          optional :seq, type: Integer, documentation: { example: 995 }
          optional :showCount, type: Integer, documentation: { example: 3 }
          optional :pageNum, type: Integer, documentation: { example: 0 }
        end
      end

      # Request URL should be /api/srch/all?srchString=QRY[&seq=KEYCOUNT&showCount=NUM_ROWS&pageNum=PAGE_NUM]
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of all available resources', hidden: false,
                                                          is_array: false,
                                                          nickname: 'srchGetAll'
      params do
        use :common
      end

      endpoint = 'all'
      create(endpoint)

      # Request URL should be /api/srch/profiles?srchString=QRY[&seq=KEYCOUNT&showCount=NUM_ROWS&pageNum=PAGE_NUM]
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of profiles', hidden: false,
                                           is_array: false,
                                           nickname: 'srchGetProfiles'

      params do
        use :common
      end
      endpoint = 'profiles'
      create(endpoint)

      # Request URL should be /api/srch/notes?srchString=QRY[&seq=KEYCOUNT&showCount=NUM_ROWS&pageNum=PAGE_NUM]
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of research notes', hidden: false,
                                                 is_array: false,
                                                 nickname: 'srchGetNotes'

      params do
        use :common
      end
      endpoint = 'notes'
      create(endpoint)

      # Request URL should be /api/srch/questions?srchString=QRY[&seq=KEYCOUNT&showCount=NUM_ROWS&pageNum=PAGE_NUM]
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of questions tables', hidden: false,
                                                   is_array: false,
                                                   nickname: 'srchGetQuestions'

      params do
        use :common
      end
      endpoint = 'questions'
      create(endpoint)

      # Request URL should be /api/srch/tags?srchString=QRY[&seq=KEYCOUNT&showCount=NUM_ROWS&pageNum=PAGE_NUM]
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of documents associated with tags within the system', hidden: false,
                                                                                   is_array: false,
                                                                                   nickname: 'srchGetByTags'

      params do
        use :common
      end
      endpoint = 'tags'
      create(endpoint)

      # Request URL should be /api/srch/locations?srchString=QRY[&seq=KEYCOUNT&showCount=NUM_ROWS&pageNum=PAGE_NUM]
      # Note: Query(QRY as above) must have latitude and longitude as srchString=lat,lon
      desc 'Perform a search of documents having nearby latitude and longitude tag values', hidden: false,
                                                                                            is_array: false,
                                                                                            nickname: 'srchGetLocations'

      params do
        use :common
        optional :tagName, type: String, documentation: { example: 'awesome' }
      end
      endpoint = 'taglocations'
      create(endpoint)

      # API TO FETCH QRY RECENT CONTRIBUTORS
      # Request URL should be /api/srch/peoplelocations?srchString=QRY[&seq=KEYCOUNT&showCount=NUM_ROWS&pageNum=PAGE_NUM]
      # QRY should be a number
      desc 'Perform a search to show x Recent People',  hidden: false,
                                                        is_array: false,
                                                        nickname: 'srchGetPeople'

      params do
        use :common
        optional :tagName, type: String, documentation: { example: 'group:partsandcrafts' }
      end

      endpoint = 'peoplelocations'
      create(endpoint)
      # end endpoint definitions
    end
  end
end
