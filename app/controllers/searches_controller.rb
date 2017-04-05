require 'search'

class SearchesController < ApplicationController
  before_filter :set_search_service
  before_filter :set_search, only: [:show, :update]

  def index
    @searches = SearchRecord.all
  end

  def test
    term = params[:q] || "spectrometer"
    @search = Node.search do
      fulltext term
    end
    render json: @search.results[0]
  end

  def new
    # Rendering advanced search form
    @title = 'Advanced search'
    @search = SearchRecord.new
    @nodes = []
  end

  def create
    @search = SearchRecord.new(searches_params)
    @search.title = 'Advanced search'

    if current_user
      @search.user_id = current_user.id
    end

    if @search.save
      redirect_to search_url(@search)
    else
      puts @search.errors
      render :new
    end
  end

  # Dynamic Search Page using RESTful API
  def dynamic
    render :dynamic
  end

  def update
    if @search.update_attributes(searches_params)
      redirect_to search_url(@search)
    else
      render :new
    end
  end

  def show
    @title = @search.title
    @solr_nodes = @search.notes(params[:month])
    @nodes = @search.note_results(params[:month])
    set_sidebar :tags, @search.key_words
  end

  def normal_search
    @title = 'Search'
    @tagnames = params[:id].split(',')
    @users = @search_service.users(params[:id])
    set_sidebar :tags, [params[:id]]

    @notes = Node.paginate(page: params[:page])
                 .order('node.nid DESC')
                 .where('(type = "note" OR type = "page" OR type = "map") AND node.status = 1 AND (node.title LIKE ? OR node_revisions.title LIKE ? OR node_revisions.body LIKE ?)', '%' + params[:id] + '%', '%' + params[:id] + '%', '%' + params[:id] + '%')
                 .includes(:drupal_node_revision)
  end

  # DEPRECATED
  # utility response to fill out search autocomplete
  # needs *dramatic* optimization

  def typeahead
    warn '[DEPRECATED] SearchesController.typeahead is deprecated.  Use the RESTful API for typeahead instead.'
    @match = @search_service.type_ahead(params[:id])
    render json: @match
  end

  def map
    @users = DrupalUsers.where('lat != 0.0 AND lon != 0.0')
  end

  private

  def set_search
    @search = SearchRecord.find(params[:id])
  end

  def set_search_service
    @search_service = SearchService.new
  end

  def searches_params
    params.require( :search_record)
           .permit( :key_words,
                   :main_type,
                   :note_type,
                   :min_date,
                   :max_date,
                   :created_by,
                   :language )
  end

end
