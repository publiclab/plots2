require 'grape'
require 'grape-entity'

module Srch
  class Search < Grape::API
    include Skylight::Helpers

    # we are using a group of reusable parameters using a shared params helper
    # see /app/api/srch/shared_params.rb
    helpers SharedParams

    include Grape::Rails::Cache

    # Endpoint definitions
    # Basic implementation from classic plots2 SearchController
    resource :srch do
      # Request URL should be /api/srch/all?query=QRY
      desc 'Perform a search of all available resources', hidden: false,
                                                          is_array: false,
                                                          nickname: 'search_all'
      params do
        use :common
      end
      get :all do
        search_request = SearchRequest.from_request(params)
        results = Search.execute(:all, params)
        results_list = []

        if results.present?
          results_list << results[:profiles].map do |model|
            DocResult.new(
              doc_type: 'USERS',
              doc_url: '/profile/' + model.name,
              doc_title: model.username
            )
          end

          results_list << results[:notes].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'NOTES',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          results_list << results[:wikis].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'WIKIS',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          results_list << results[:tags].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'TAGS',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          results_list << results[:maps].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'PLACES',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          results_list << results[:questions].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'QUESTIONS',
              doc_url: model.path(:question),
              doc_title: model.title,
              score: model.answers.length
            )
          end
          DocList.new(results_list.flatten, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Request URL should be /api/srch/profiles?query=QRY[&sort_by=recent&order_direction=desc&field=username]
      desc 'Perform a search of profiles', hidden: false,
                                           is_array: false,
                                           nickname: 'search_profiles'

      params do
        use :common, :sorting, :ordering, :field
      end
      get :profiles do
        search_request = SearchRequest.from_request(params)
        # TODO: evaluate if disabling this caching action actually speeds things up?
        cache(key: "api:profiles:#{params[:query]}:#{params[:limit]}:#{params[:sort_by]}:#{params[:order_direction]}:#{params[:field]}", expires_in: 2.day) do
          results = Search.execute(:profiles, params)

          if results.present?
            docs = results.map do |model|
              DocResult.new(
                doc_type: 'USERS',
                doc_url: '/profile/' + model.name,
                doc_title: model.username,
                latitude: model.lat,
                longitude: model.lon,
                blurred: model.blurred?
              )
            end
            DocList.new(docs, search_request)
          else
            DocList.new('', search_request)
          end
        end
      end

      # Request URL should be /api/srch/notes?query=QRY
      desc 'Perform a search of research notes', hidden: false,
                                                 is_array: false,
                                                 nickname: 'search_notes'

      params do
        use :common
      end
      get :notes do
        search_request = SearchRequest.from_request(params)
        results = Search.execute(:notes, params)

        if results.present?
          docs = results.map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'NOTES',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Request URL should be /api/srch/content?query=QRY
      desc 'Perform a search of nodes and tags', hidden: false,
                                                 is_array: false,
                                                 nickname: 'search_content'

      params do
        use :common
      end
      get :content do
        search_request = SearchRequest.from_request(params)
        results = Search.execute(:content, params)
        results_list = []

        if results.present?
          results_list << results[:tags].map do |tagname|
            DocResult.new(
              doc_id: tagname,
              doc_type: 'TAGS',
              doc_url: "/tag/#{tagname}",
              doc_title: tagname
            )
          end
          results_list << results[:notes].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'NOTES',
              doc_url: model.path,
              doc_title: model.title
            )
          end
          DocList.new(results_list.flatten, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Request URL should be /api/srch/nodes?query=QRY
      desc 'Perform a search of nodes', hidden: false,
                                                 is_array: false,
                                                 nickname: 'search_content'

      params do
        use :common
      end
      get :nodes do
        search_request = SearchRequest.from_request(params)
        results = Search.execute(:nodes, params)

        if results.present?
          docs = results.map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'NODES',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Request URL should be /api/srch/wikis?query=QRY
      desc 'Perform a search of wikis pages',    hidden: false,
                                                 is_array: false,
                                                 nickname: 'search_wikis'

      params do
        use :common
      end
      get :wikis do
        search_request = SearchRequest.from_request(params)
        results = Search.execute(:wikis, params)

        if results.present?
          docs = results.map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'WIKIS',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Request URL should be /api/srch/questions?query=QRY
      desc 'Perform a search of questions tables', hidden: false,
                                                   is_array: false,
                                                   nickname: 'search_questions'

      params do
        use :common, :sorting, :ordering
      end
      get :questions do
        search_request = SearchRequest.from_request(params)
        results = Search.execute(:questions, params)

        if results.present?
          docs = results.map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'QUESTIONS',
              doc_url: model.path(:question),
              doc_title: model.title,
              score: model.answers.length
            )
          end

          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Request URL should be /api/srch/tags?query=QRY
      desc 'Perform a search of documents associated with tags within the system', hidden: false,
                                                                                   is_array: false,
                                                                                   nickname: 'search_tags'

      params do
        use :common
      end
      get :tags do
        Skylight.instrument title: "Tags search" do
          search_request = SearchRequest.from_request(params)
          results = Search.execute(:tags, params)

          if results.present?
            docs = results.map do |model|
              DocResult.new(
                doc_id: model.nid,
                doc_type: 'TAGS',
                doc_url: model.path,
                doc_title: model.title
              )
            end

            DocList.new(docs, search_request)
          else
            DocList.new('', search_request)
          end
        end
      end

      # Request URL should be /api/srch/taglocations?nwlat=200.0&selat=0.0&nwlng=0.0&selng=200.0[&tag=awesome]
      desc 'Perform a search of documents having nearby latitude and longitude tag values', hidden: false,
                                                                                            is_array: false,
                                                                                            nickname: 'search_tag_locations'

      params do
        use :geographical, :additional, :period, :sorting, :ordering
      end
      get :taglocations do
        search_request = SearchRequest.from_request(params)
        results = Search.execute(:taglocations, params)

        if results.present?
          docs = results.map do |model|
            doctype = model.has_power_tag('question') ? 'QUESTION' : 'NOTE'
            doctype = 'WIKI' if model.type == 'page'
            DocResult.new(
              doc_id: model.nid,
              doc_type: doctype,
              doc_url: model.path(:items),
              doc_title: model.title,
              doc_author: model.user.username,
              doc_image_url: !model.images.empty? ? model.images.first.path : 0,
              score: model.answers.length,
              latitude: model.lat,
              longitude: model.lon,
              blurred: model.blurred?,
              place_name: model.has_power_tag('place') ? model.power_tag('place') : '',
              created_at: model.created_at,
              # time_since: distance_of_time_in_words(model.created_at, Time.current, { include_seconds: false, scope: 'datetime.time_ago_in_words' }),  # works, but really slows down the search results
              # comment_count: model.comments_viewable_by(current_user).length  # causes an error because of current_user?
            )
          end
          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Request URL should be /api/srch/nearbyPeople?nwlat=200.0&selat=0.0&nwlng=0.0&selng=200.0[&tag=awesome&sort_by=recent]
      desc 'Perform a search to show people nearby a given location',  hidden: false,
                                                                       is_array: false,
                                                                       nickname: 'search_nearby_people'
      params do
        use :geographical, :additional, :field, :period, :sorting, :ordering
      end
      get :nearbyPeople do
        search_request = SearchRequest.from_request(params)
        results = Search.execute(:nearbyPeople, params)

        if results.present?
          docs = results.map do |model|
            DocResult.new(
              doc_id: model.id,
              doc_type: 'PLACES',
              doc_url: model.path,
              doc_title: model.username,
              latitude: model.lat,
              longitude: model.lon,
              blurred: model.blurred?,
              created_at: model.created_at,
              doc_image_url: model.profile_image ? model.profile_image : ""
            )
          end
          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Request URL should be /api/srch/places?query=QRY
      desc 'Perform a search of places',           hidden: false,
                                                   is_array: false,
                                                   nickname: 'search_places'

      params do
        use :common
      end
      get :places do
        search_request = SearchRequest.from_request(params)
        results = Search.execute(:places, params)

        if results.present?
          docs = results.map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'PLACES',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end
    end

    def self.execute(endpoint, params)
      search_type = endpoint
      search_criteria = SearchCriteria.new(params)
      search_criteria.validate_period_from_to
      if search_criteria.valid?
        ExecuteSearch.new.by(search_type, search_criteria)
      else
        []
      end
    end
  end
end
