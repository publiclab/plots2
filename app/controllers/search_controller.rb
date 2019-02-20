class SearchController < ApplicationController
  include TextSearch
  before_action :set_search_criteria, :except => %i(notes wikis)

  def new; end

  def notes
    @notes = SearchService.new.search_notes(params[:query], 15, params[:order].to_s.to_sym, params[:type].to_s.to_sym)
                              .paginate(page: params[:page], per_page: 24)
  end

  def wikis
    @wikis = SearchService.new.search_wikis(params[:query], 15, params[:order].to_s.to_sym, params[:type].to_s.to_sym)
                              .paginate(page: params[:page], per_page: 24)
  end

  def profiles
    @search_criteria.sort_by = "recent"
    @profiles = ExecuteSearch.new.by(:profiles, @search_criteria).paginate(page: params[:page], per_page: 20)
    @tag_profiles = SearchService.new.find_users(params[:query], 15, 'tag').paginate(page: params[:page], per_page: 20)
  end

  def questions
    @questions = add_extra_results_for_transformed_queries(:questions)
  end

  def places
    # it's called nodes because the map/_maps partials expects nodes objects
    @places = add_extra_results_for_transformed_queries(:places)
  end

  def tags
    @tags = add_extra_results_for_transformed_queries(:tags)
  end

  def all_content
    @nodes = ExecuteSearch.new.by(:all, @search_criteria)
    @additional_search_querys.each do |added_search_criteria|
      added_criteria_result = ExecuteSearch.new.by(:all, added_search_criteria)
      added_criteria_result.each do |key, val|
        @nodes[key] = @nodes[key] + val
      end
    end
    @nodes.each_key do |key|
      @nodes[key] = @nodes[key].uniq
    end
    @wikis = @nodes[:wikis]
    @notes = @nodes[:notes]
    @profiles = @nodes[:profiles]
    @questions = @nodes[:questions]
    @tags = @nodes[:tags]
  end

  private

  def set_search_criteria
    @search_criteria = SearchCriteria.new(params)
    @additional_search_querys = []
    if params[:query].present?
      if params[:query].include? "-"
        params[:query] = non_hyphenate_query(@search_criteria.query)
        @additional_search_querys << SearchCriteria.new(params)
      end
      params[:query] = results_with_probable_hyphens(@search_criteria.query)
      @additional_search_querys << SearchCriteria.new(params)
    end
  end

  def add_extra_results_for_transformed_queries(type)
    search_type_object = ExecuteSearch.new.by(type, @search_criteria)
    @additional_search_querys.each do |added_search_criteria|
      search_type_object += ExecuteSearch.new.by(type, added_search_criteria)
    end
    search_type_object = search_type_object.uniq
    search_type_object = search_type_object.paginate(page: params[:page], per_page: 20)
  end

  def search_params
    params.require(:search).permit(:query, :order)
  end
end
