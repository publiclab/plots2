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
    @questions = search_executor.by(:questions, @search_criteria)
    @added_search_criteria.each do |added_search_criteria|
      @questions = @questions + search_executor.by(:questions, added_search_criteria)
    end
    @questions = @questions.uniq
    @questions = @questions.paginate(page: params[:page], per_page: 20)
  end

  def places
    # it's called nodes because the map/_maps partials expects nodes objects
    @nodes = search_executor.by(:places, @search_criteria)
    @additional_search_querys.each do |added_search_criteria|
      @nodes = @nodes + search_executor.by(:places, added_search_criteria)
    end
    @nodes = @nodes.uniq
    @nodes = @nodes.paginate(page: params[:page], per_page: 20)
  end

  def tags
    @tags = search_executor.by(:tags, @search_criteria)
    @added_search_criteria.each do |added_search_criteria|
      @tags = @tags + search_executor.by(:tags, added_search_criteria)
    end
    @tags = @tags.uniq
    @tags = @tags.paginate(page: params[:page], per_page: 20)
  end

  def all_content
    @nodes = ExecuteSearch.new.by(:all, @search_criteria)
    @additional_search_querys.each do |added_search_criteria|
      added_criteria_result = ExecuteSearch.new.by(:all, added_search_criteria)
      added_criteria_result.each do |key, val|
        @nodes[key] = @nodes[key] + val
      end
    end
    @wikis = @nodes[:wikis].uniq
    @notes = @nodes[:notes].uniq
    @profiles = @nodes[:profiles].uniq
    @questions = @nodes[:questions].uniq
    @tags = @nodes[:tags].uniq
  end

  private

  def set_search_criteria
    @search_criteria = SearchCriteria.new(params)
    @additional_search_querys = []
    if params[:query].include? "-"
      params[:query] = non_hyphenate_query(@search_criteria.query)
      @additional_search_querys << SearchCriteria.new(params)
    end
    params[:query] = results_with_probable_hyphens(@search_criteria.query)
    @additional_search_querys << SearchCriteria.new(params)
    search_executor = ExecuteSearch.new
  end

  def search_params
    params.require(:search).permit(:query, :order)
  end
end
