require 'grape'
require 'grape-entity'

module Srch
  class Search < Grape::API
    include Skylight::Helpers

    # Using shared parameters defined in a helper module
    helpers SharedParams

    include Grape::Rails::Cache

    # Main API resource for search-related endpoints
    resource :srch do

      # Endpoint to search across all available resources (profiles, notes, tags, etc.)
      get :all do
        search_request = SearchRequest.from_request(params)
        results = Search.execute(:all, params)
        results_list = []

        if results.present?
          # Mapping profile results
          results_list << results[:profiles].map do |model|
            DocResult.new(
              doc_type: 'USERS',
              doc_url: "/profile/#{model.name}",
              doc_title: model.username
            )
          end

          # Mapping notes results
          results_list << results[:notes].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'NOTES',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          # Mapping wiki results
          results_list << results[:wikis].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'WIKIS',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          # Mapping tag results
          results_list << results[:tags].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'TAGS',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          # Mapping map/location results
          results_list << results[:maps].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'PLACES',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          # Mapping question results with score based on comments
          results_list << results[:questions].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'QUESTIONS',
              doc_url: model.path(:question),
              doc_title: model.title,
              score: model.comments.length
            )
          end

          DocList.new(results_list.flatten, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Endpoint to search user profiles
      get :profiles do
        search_request = SearchRequest.from_request(params)

        # Caching results for performance improvement
        cache(key: "api:profiles:#{params[:query]}:#{params[:limit]}:#{params[:sort_by]}:#{params[:order_direction]}:#{params[:field]}", expires_in: 2.day) do
          results = Search.execute(:profiles, params)

          if results.present?
            docs = results.map do |model|
              DocResult.new(
                doc_type: 'USERS',
                doc_url: "/profile/#{model.name}",
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

      # Endpoint to search research notes
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

      # Endpoint to search tags and notes together
      get :content do
        search_request = SearchRequest.from_request(params)
        results = Search.execute(:content, params)
        results_list = []

        if results.present?
          # Mapping tag names
          results_list << results[:tags].map do |tagname|
            DocResult.new(
              doc_id: tagname,
              doc_type: 'TAGS',
              doc_url: "/tag/#{tagname}",
              doc_title: tagname
            )
          end

          # Mapping note results
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

      # Endpoint to search nodes
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

      # Endpoint to search wiki pages
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

      # Endpoint to search questions
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
              score: model.comments.length
            )
          end
          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Endpoint to search tags
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

      # Endpoint to search locations based on geographical bounds
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
              doc_image_url: model.images.empty? ? 0 : model.images.first.path,
              score: model.comments.length,
              latitude: model.lat,
              longitude: model.lon,
              blurred: model.blurred?,
              place_name: model.has_power_tag('place') ? model.power_tag('place') : '',
              created_at: model.created_at
            )
          end
          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Endpoint to find nearby people based on location
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
              doc_image_url: model.profile_image || ""
            )
          end
          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Endpoint to search places
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

    # Executes search based on endpoint type and validated criteria
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
