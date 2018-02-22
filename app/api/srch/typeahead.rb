require 'grape'
require 'grape-entity'

module Srch
  class Typeahead < Grape::API
    # Number of top values of each type to return
    TYPEAHEAD_LIMIT = 10

    # Endpoint definitions
    resource :typeahead do
      # Request URL should be /api/typeahead/all?srchString=QRY&seq=KEYCOUNT
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of all available resources', hidden: false,
                                                          is_array: false,
                                                          nickname: 'typeaheadGetAll'
      params do
        requires :srchString, type: String, documentation: { example: 'Spec' }
        optional :seq, type: Integer, documentation: { example: 995 }
      end
      get :all do
        sresult = TagList.new
        sparms = SearchRequest.fromRequest(params)
        if sparms.valid?
          sresult = TypeaheadService.new.search_all(params[:srchString], TYPEAHEAD_LIMIT)
        end
        sresult.srchParams = sparms
        present sresult, with: TagList::Entity
      end

      # Request URL should be /api/typeahead/profiles?srchString=QRY&seq=KEYCOUNT
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of profiles', hidden: false,
                                           is_array: false,
                                           nickname: 'typeaheadGetProfiles'
      params do
        requires :srchString, type: String, documentation: { example: 'Spec' }
        optional :seq, type: Integer, documentation: { example: 995 }
      end
      get :profiles do
        sresult = TagList.new
        sparms = SearchRequest.fromRequest(params)
        if sparms.valid?
          sresult = TypeaheadService.new.search_profiles(params[:srchString], TYPEAHEAD_LIMIT)
        end
        sresult.srchParams = sparms
        present sresult, with: TagList::Entity
      end

      # Request URL should be /api/typeahead/notes?srchString=QRY&seq=KEYCOUNT
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of research notes', hidden: false,
                                                 is_array: false,
                                                 nickname: 'typeaheadGetNotes'
      params do
        requires :srchString, type: String, documentation: { example: 'Spec' }
        optional :seq, type: Integer, documentation: { example: 995 }
      end
      get :notes do
        sresult = TagList.new
        sparms = SearchRequest.fromRequest(params)
        if sparms.valid?
          sresult = TypeaheadService.new.search_notes(params[:srchString], TYPEAHEAD_LIMIT)
        end
        sresult.srchParams = sparms
        present sresult, with: TagList::Entity
      end

      # Request URL should be /api/typeahead/questions?srchString=QRY&seq=KEYCOUNT
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of questions tables', hidden: false,
                                                   is_array: false,
                                                   nickname: 'typeaheadGetQuestions'
      params do
        requires :srchString, type: String, documentation: { example: 'Spec' }
        optional :seq, type: Integer, documentation: { example: 995 }
      end
      get :questions do
        sresult = TagList.new
        sparms = SearchRequest.fromRequest(params)
        if sparms.valid?
          sresult = TypeaheadService.new.search_questions(params[:srchString], TYPEAHEAD_LIMIT)
        end
        sresult.srchParams = sparms
        present sresult, with: TagList::Entity
      end

      # Request URL should be /api/typeahead/tags?srchString=QRY&seq=KEYCOUNT
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of tags within the system', hidden: false,
                                                         is_array: false,
                                                         nickname: 'typeaheadGetTags'
      params do
        requires :srchString, type: String, documentation: { example: 'Spec' }
        optional :seq, type: Integer, documentation: { example: 995 }
      end
      get :tags do
        sresult = TagList.new
        sparms = SearchRequest.fromRequest(params)
        if sparms.valid?
          TypeaheadService.new.search_tags(params[:srchString], TYPEAHEAD_LIMIT)
        end
        sresult.srchParams = sparms
        present sresult, with: TagList::Entity
      end

      # Request URL should be /api/typeahead/comments?srchString=QRY&seq=KEYCOUNT
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of comments within the system', hidden: false,
                                                         is_array: false,
                                                         nickname: 'typeaheadGetComments'
      params do
        requires :srchString, type: String, documentation: { example: 'Spec' }
        optional :seq, type: Integer, documentation: { example: 995 }
      end
      get :comments do
        sresult = TagList.new
        sparms = SearchRequest.fromRequest(params)
        if sparms.valid?
          TypeaheadService.new.search_comments(params[:srchString], TYPEAHEAD_LIMIT)
        end
        sresult.srchParams = sparms
        present sresult, with: TagList::Entity
      end

      # end of endpoint definitions
    end
  end
end
