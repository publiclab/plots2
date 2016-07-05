class SearchesController < ApplicationController

  before_filter :set_search_service
  before_filter :set_search, only: [:show, :update]

  def index
    @searches = Search.all
  end

  def new
    # Rendering advanced search form
    @title = 'Advanced search'
    @search = Search.new
    @nodes = []
  end

  def create
    @search = Search.new(search_params)
    @search.title = 'Advanced search'
    @search.user_id = current_user.id
    if @search.save
      redirect_to @search
    else
      puts 'search failed !'
      render :new
    end
  end

  # Dynamic Search Page using RESTful API
  def dynamic
   @search = Search.new(search_params)
   @search.title = 'Dynamic Search Page'
   @search.user_id = current_user.id
   render :dynamic
  end

  def update
    if @search.update_attributes(search_params)
      redirect_to @search
    else
      render :new
    end
  end

  def show
    @title = @search.title
    @nodes = @search.nodes
    set_sidebar :tags, @search.key_words
  end

  def normal_search
    @title = 'Search'
    @tagnames = params[:id].split(',')
    @users = @search_service.users(params[:id])
    set_sidebar :tags, [params[:id]]

    @notes = DrupalNode.paginate(page: params[:page])
                 .order('node.nid DESC')
                 .where('(type = "note" OR type = "page" OR type = "map") AND node.status = 1 AND (node.title LIKE ? OR node_revisions.title LIKE ? OR node_revisions.body LIKE ?)', "%"+params[:id]+"%","%"+params[:id]+"%","%"+params[:id]+"%")
                 .includes(:drupal_node_revision)
  end

  # deprecated 
  # utility response to fill out search autocomplete
  # needs *dramatic* optimization
  def typeahead
    @match = @search_service.type_ahead(params[:id])
    render json: @match
  end

  def map
    @users = DrupalUsers.where("lat != 0.0 AND lon != 0.0")
  end

  private

    def set_search
      @search = Search.find(params[:id])
    end

    def set_search_service
      @search_service = SearchService.new
    end

    def search_params
      params.require(:search).permit(:key_words, :main_type, :note_type,
                                     :min_date, :max_date, :created_by, :language)
    end

end
