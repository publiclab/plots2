require 'grape'
require 'grape-entity'

module Search
  class Search < Grape::API
    # Endpoint definitions
    resource :srch do
      # Request URL should be /api/srch/all?srchString=QRY[&seq=KEYCOUNT&showCount=NUM_ROWS&pageNum=PAGE_NUM]
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of all available resources', hidden: false,
                                                          is_array: false,
                                                          nickname: 'srchGetAll'
      params do
        requires :srchString, type: String, documentation: { example: 'Spec' }
        optional :seq, type: Integer, documentation: { example: 995 }
        optional :showCount, type: Integer, documentation: { example: 3 }
        optional :pageNum, type: Integer, documentation: { example: 0 }
      end
      get :all do
        sresult = DocList.new
        unless params[:srchString].nil? || params[:srchString] == 0
          sservice = SearchService.new
          sresult = sservice.textSearch_all(params[:srchString])
        end
        sparms = SearchRequest.fromRequest(params)
        sresult.srchParams = sparms
        sresult
      end

      # Request URL should be /api/srch/profiles?srchString=QRY[&seq=KEYCOUNT&showCount=NUM_ROWS&pageNum=PAGE_NUM]
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of profiles', hidden: false,
                                           is_array: false,
                                           nickname: 'srchGetProfiles'
      params do
        requires :srchString, type: String, documentation: { example: 'Spec' }
        optional :seq, type: Integer, documentation: { example: 995 }
        optional :showCount, type: Integer, documentation: { example: 3 }
        optional :pageNum, type: Integer, documentation: { example: 0 }
      end
      get :profiles do
        sresult = DocList.new
        unless params[:srchString].nil? || params[:srchString] == 0
          sservice = SearchService.new
          sresult = sservice.textSearch_profiles(params[:srchString])
        end
        sparms = SearchRequest.fromRequest(params)
        sresult.srchParams = sparms
        sresult
      end

      # Request URL should be /api/srch/notes?srchString=QRY[&seq=KEYCOUNT&showCount=NUM_ROWS&pageNum=PAGE_NUM]
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of research notes', hidden: false,
                                                 is_array: false,
                                                 nickname: 'srchGetNotes'
      params do
        requires :srchString, type: String, documentation: { example: 'Spec' }
        optional :seq, type: Integer, documentation: { example: 995 }
        optional :showCount, type: Integer, documentation: { example: 3 }
        optional :pageNum, type: Integer, documentation: { example: 0 }
      end
      get :notes do
        sresult = DocList.new
        unless params[:srchString].nil? || params[:srchString] == 0
          sservice = SearchService.new
          sresult = sservice.textSearch_notes(params[:srchString])
        end
        sparms = SearchRequest.fromRequest(params)
        sresult.srchParams = sparms
        sresult
      end

      # Request URL should be /api/srch/questions?srchString=QRY[&seq=KEYCOUNT&showCount=NUM_ROWS&pageNum=PAGE_NUM]
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of questions tables', hidden: false,
                                                   is_array: false,
                                                   nickname: 'srchGetQuestions'
      params do
        requires :srchString, type: String, documentation: { example: 'Spec' }
        optional :seq, type: Integer, documentation: { example: 995 }
        optional :showCount, type: Integer, documentation: { example: 3 }
        optional :pageNum, type: Integer, documentation: { example: 0 }
      end
      get :questions do
        sresult = DocList.new
        unless params[:srchString].nil? || params[:srchString] == 0
          sservice = SearchService.new
          sresult = sservice.textSearch_questions(params[:srchString])
        end
        sparms = SearchRequest.fromRequest(params)
        sresult.srchParams = sparms
        sresult
      end

      # Request URL should be /api/srch/tags?srchString=QRY[&seq=KEYCOUNT&showCount=NUM_ROWS&pageNum=PAGE_NUM]
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of documents associated with tags within the system', hidden: false,
                                                                                   is_array: false,
                                                                                   nickname: 'srchGetByTags'
      params do
        requires :srchString, type: String, documentation: { example: 'Spec' }
        optional :seq, type: Integer, documentation: { example: 995 }
        optional :showCount, type: Integer, documentation: { example: 3 }
        optional :pageNum, type: Integer, documentation: { example: 0 }
      end
      get :tags do
        sresult = DocList.new
        unless params[:srchString].nil? || params[:srchString] == 0
          sservice = SearchService.new
          sresult = sservice.textSearch_tags(params[:srchString])
        end
        sparms = SearchRequest.fromRequest(params)
        sresult.srchParams = sparms
        sresult
      end

      # end endpoint definitions
    end
  end
end
