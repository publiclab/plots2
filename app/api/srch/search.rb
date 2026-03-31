require 'grape'
require 'grape-entity'

module Srch
  class Search < Grape::API
    include Skylight::Helpers

    helpers SharedParams
    include Grape::Rails::Cache

    resource :srch do

      desc 'Perform a search of all available resources', hidden: false,
                                                          is_array: false,
                                                          nickname: 'search_all'
      params do
        use :common
      end
      get :all do
        # Query sanitization
        params[:query] = params[:query].to_s.strip.downcase if params[:query]

        search_request = SearchRequest.from_request(params)
        results = Search.execute(:all, params)
        results_list = []

        if results.present?
          results_list << results[:profiles].map do |model|
            DocResult.new(
              doc_type: 'USERS',
              doc_url: "/profile/#{model.name}",
              doc_title: model.username || "Unknown User"
            )
          end

          results_list << results[:notes].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'NOTES',
              doc_url: model.path,
              doc_title: model.title || "Untitled"
            )
          end

          results_list << results[:wikis].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'WIKIS',
              doc_url: model.path,
              doc_title: model.title || "Untitled"
            )
          end

          results_list << results[:tags].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'TAGS',
              doc_url: model.path,
              doc_title: model.title || "Untitled"
            )
          end

          results_list << results[:maps].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'PLACES',
              doc_url: model.path,
              doc_title: model.title || "Untitled"
            )
          end

          results_list << results[:questions].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'QUESTIONS',
              doc_url: model.path(:question),
              doc_title: model.title || "Untitled",
              score: model.comments.length
            )
          end

          DocList.new(results_list.flatten, search_request)
        else
          DocList.new('', search_request)
        end
      end

      desc 'Perform a search of research notes', hidden: false,
                                                 is_array: false,
                                                 nickname: 'search_notes'
      params do
        use :common
      end
      get :notes do
        # Query sanitization
        params[:query] = params[:query].to_s.strip.downcase if params[:query]

        search_request = SearchRequest.from_request(params)
        results = Search.execute(:notes, params)

        if results.present?
          docs = results.map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'NOTES',
              doc_url: model.path,
              doc_title: model.title || "Untitled"
            )
          end
          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end

      desc 'Perform a search of documents associated with tags within the system', hidden: false,
                                                                                   is_array: false,
                                                                                   nickname: 'search_tags'
      params do
        use :common
      end
      get :tags do
        # Query sanitization
        params[:query] = params[:query].to_s.strip.downcase if params[:query]

        Skylight.instrument title: "Tags search" do
          search_request = SearchRequest.from_request(params)
          results = Search.execute(:tags, params)

          if results.present?
            docs = results.map do |model|
              DocResult.new(
                doc_id: model.nid,
                doc_type: 'TAGS',
                doc_url: model.path,
                doc_title: model.title || "Untitled"
              )
            end
            DocList.new(docs, search_request)
          else
            DocList.new('', search_request)
          end
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
