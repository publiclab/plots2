require 'grape'
require 'grape-entity'

module Srch
  class Typeahead < Grape::API
    # we are using a group of reusable parameters using a shared params helper
    # see /app/api/srch/shared_params.rb
    helpers SharedParams
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
        use :commontypeahead
      end
      get :all do
        present Typeahead.execute(:all, params), with: TagList::Entity
      end

      # Request URL should be /api/typeahead/profiles?srchString=QRY&seq=KEYCOUNT
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of profiles', hidden: false,
                                           is_array: false,
                                           nickname: 'typeaheadGetProfiles'
      params do
        use :commontypeahead
      end
      get :profiles do
        present Typeahead.execute(:profiles, params), with: TagList::Entity
      end

      # Request URL should be /api/typeahead/notes?srchString=QRY&seq=KEYCOUNT
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of research notes', hidden: false,
                                                 is_array: false,
                                                 nickname: 'typeaheadGetNotes'
      params do
        use :commontypeahead
      end
      get :notes do
        present Typeahead.execute(:notes, params), with: TagList::Entity
      end

      # Request URL should be /api/typeahead/questions?srchString=QRY&seq=KEYCOUNT
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of questions tables', hidden: false,
                                                   is_array: false,
                                                   nickname: 'typeaheadGetQuestions'
      params do
        use :commontypeahead
      end
      get :questions do
        present Typeahead.execute(:questions, params), with: TagList::Entity
      end

      # Request URL should be /api/typeahead/tags?srchString=QRY&seq=KEYCOUNT
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of tags within the system', hidden: false,
                                                         is_array: false,
                                                         nickname: 'typeaheadGetTags'
      params do
        use :commontypeahead
      end
      get :tags do
        present Typeahead.execute(:tags, params), with: TagList::Entity
      end

      # Request URL should be /api/typeahead/comments?srchString=QRY&seq=KEYCOUNT
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of comments within the system', hidden: false,
                                                         is_array: false,
                                                         nickname: 'typeaheadGetComments'
      params do
        use :commontypeahead
      end
      get :comments do
        present Typeahead.execute(:comments, params), with: TagList::Entity
      end

      # end of endpoint definitions
    end

    def self.execute(endpoint, params)
      sresult = TagList.new
      search_query = params[:srchString]
      search_type = endpoint
      search_criteria = SearchCriteria.new(search_query)

      if search_criteria.valid?
        sresult = ExecuteTypeahead.new.by(search_type, search_criteria, TYPEAHEAD_LIMIT)
      end

      sparms = SearchRequest.fromRequest(params)
      sresult.srchParams = sparms
      sresult
    end
  end
end
