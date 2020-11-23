class SearchController < ApplicationController
  before_action :set_search_criteria, except: %i(notes wikis)

  def new; end

  def google
    @title = "Search"
  end

  # a route to convert /search/_____ to /search?q=______ style search queries
  def google_redirect
    redirect_to '/search?q=' + params[:query]
  end

  def notes
    @title = "Search notes"
    @notes = SearchService.new.search_notes(params[:query], 15, params[:order].to_s.to_sym, params[:type].to_s.to_sym)
                              .paginate(page: params[:page], per_page: 24)
  end

  def wikis
    @title = "Search wikis"
    @wikis = SearchService.new.search_wikis(params[:query], 15, params[:order].to_s.to_sym, params[:type].to_s.to_sym)
                              .paginate(page: params[:page], per_page: 24)
  end

  def profiles
    @title = "Search profiles"
    @search_criteria.sort_by = "recent"
    if params[:query]
      @pagy, @profiles = pagy(ExecuteSearch.new.by(:profiles, @search_criteria), items: 20)
    else
      @profiles = []
      @unpaginated = true
    end
    @tag_profiles = SearchService.new.find_users(params[:query], 15, 'tag').paginate(page: params[:page], per_page: 20)
  end

  def questions
    @title = "Search questions"
    @questions = ExecuteSearch.new.by(:questions, @search_criteria).paginate(page: params[:page], per_page: 20)
  end

  def places
    @title = "Search maps"
    # it's called nodes because the map/_maps partials expects nodes objects
    @nodes = ExecuteSearch.new.by(:places, @search_criteria).paginate(page: params[:page], per_page: 20)
  end

  def tags
    @title = "Search tags"
    @pagy, @tags = pagy_array(ExecuteSearch.new.by(:tags, @search_criteria), items: 20)
  end

  def all_content
    @title = "Search all content"
    @nodes = ExecuteSearch.new.by(:all, @search_criteria)
    @wikis = wikis
    @notes = notes
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
