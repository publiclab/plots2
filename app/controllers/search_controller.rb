class SearchController < ApplicationController
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
  end

  def questions
    @questions = ExecuteSearch.new.by(:questions, @search_criteria).paginate(page: params[:page], per_page: 20)
  end

  def places
    # it's called nodes because the map/_maps partials expects nodes objects
    @nodes = ExecuteSearch.new.by(:places, @search_criteria).paginate(page: params[:page], per_page: 20)
  end

  def tags
    @tags = ExecuteSearch.new.by(:tags, @search_criteria).paginate(page: params[:page], per_page: 20)
  end

  def all_content
    @nodes = ExecuteSearch.new.by(:all, @search_criteria)
    @wikis = @nodes[:wikis]
    @notes = @nodes[:notes]
    @profiles = @nodes[:profiles]
    @questions = @nodes[:questions]
    @tags = @nodes[:tags]
  end

  private

  def set_search_criteria
    @search_criteria = SearchCriteria.new(params)
  end

  def search_params
    params.require(:search).permit(:query, :order)
  end
end
