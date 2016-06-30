require 'grape'
require 'grape-entity'

module Srch
  class Typeahead < Grape::API

    # Endpoint definitions
    resource :typeahead do

      # Request URL should be /api/typeahead/all?srchString=QRY&seq=KEYCOUNT
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of all available resources', {
        hidden: false,
        is_array: false,
        nickname: 'typeaheadGetAll'
      }
      params do
        requires :srchString, type: String, documentation: { example: 'Spec' }
        optional :seq, type: Integer, documentation: { example: 995 }
      end
      get :all do
        sresult = DocList.new
        unless params[:srchString].nil? || params[:srchString] == 0
          sservice = SearchService.new
          sresult = sservice.textSearch_all(params[:srchString])
        end
        sparms = SearchRequest.new(params[:srchString],params[:seq])
        sresult.srchParams=sparms
	sresult
      end

      # Request URL should be /api/typeahead/profiles?srchString=QRY&seq=KEYCOUNT
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of profiles', {
        hidden: false,
        is_array: false,
        nickname: 'typeaheadGetProfiles'
      }
      params do
        requires :srchString, type: String, documentation: { example: 'Spec' }
        optional :seq, type: Integer, documentation: { example: 995 }
      end
      get :profiles do
        sresult = DocList.new
        unless params[:srchString].nil? || params[:srchString] == 0
          sservice = SearchService.new
          sresult = sservice.textSearch_profiles(params[:srchString])
        end
        sparms = SearchRequest.new(params[:srchString],params[:seq])
        sresult.srchParams=sparms
	sresult
      end

      # Request URL should be /api/typeahead/notes?srchString=QRY&seq=KEYCOUNT
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of research notes', {
        hidden: false,
        is_array: false,
        nickname: 'typeaheadGetNotes'
      }
      params do
        requires :srchString, type: String, documentation: { example: 'Spec' }
        optional :seq, type: Integer, documentation: { example: 995 }
      end
      get :notes do
        sresult = DocList.new
        unless params[:srchString].nil? || params[:srchString] == 0
          sservice = SearchService.new
          sresult = sservice.textSearch_notes(params[:srchString])
        end
        sparms = SearchRequest.new(params[:srchString],params[:seq])
        sresult.srchParams=sparms
	sresult
      end

      # Request URL should be /api/typeahead/questions?srchString=QRY&seq=KEYCOUNT
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of questions tables', {
        hidden: false,
        is_array: false,
        nickname: 'typeaheadGetQuestions'
      }
      params do
        requires :srchString, type: String, documentation: { example: 'Spec' }
        optional :seq, type: Integer, documentation: { example: 995 }
      end
      get :questions do
        sresult = DocList.new
        unless params[:srchString].nil? || params[:srchString] == 0
          sservice = SearchService.new
          sresult = sservice.textSearch_questions(params[:srchString])
        end
        sparms = SearchRequest.new(params[:srchString],params[:seq])
        sresult.srchParams=sparms
	sresult
      end

      # Request URL should be /api/typeahead/tags?srchString=QRY&seq=KEYCOUNT
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of tags within the system', {
        hidden: false,
        is_array: false,
        nickname: 'typeaheadGetTags'
      }
      params do
        requires :srchString, type: String, documentation: { example: 'Spec' }
        optional :seq, type: Integer, documentation: { example: 995 }
      end
      get :tags do
        sresult = TagList.new
        unless params[:srchString].nil? || params[:srchString] == 0
          sservice = SearchService.new
          sresult = sservice.textSearch_tags(params[:srchString])
        end
        sparms = SearchRequest.new(params[:srchString],params[:seq])
        sresult.srchParams=sparms
	sresult
      end

    # end of endpoint definitions
    end

  end
end
