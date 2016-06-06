class SearchController < ApplicationController

  def index

  end

  def new
    # Render advanced search form
    @search = Search.new
  end

  def create
    if @search.save
      render
    end
  end

  def show

  end

  def normal_search
    @title = "Search"
    @tagnames = params[:id].split(',')
    @users = DrupalUsers.where('name LIKE ? AND access != 0', "%"+params[:id]+"%")
                        .order("uid")
                        .limit(5)
    set_sidebar :tags, [params[:id]]
    @notes = DrupalNode.paginate(page: params[:page])
                       .order("node.nid DESC")
                       .where('(type = "note" OR type = "page" OR type = "map") AND node.status = 1 AND (node.title LIKE ? OR node_revisions.title LIKE ? OR node_revisions.body LIKE ?)', "%"+params[:id]+"%","%"+params[:id]+"%","%"+params[:id]+"%")
                       .includes(:drupal_node_revision)
    render :template => 'search/index'
  end

  def advanced
    @title = "Advanced search"
    all = !params[:notes] && !params[:wikis] && !params[:maps] && !params[:comments]
    @nodes = []
    unless params[:id].nil?
      @nodes += DrupalNode.limit(25)
                          .order("nid DESC")
                          .where('type = "note" AND node.status = 1 AND title LIKE ?', "%" + params[:id] + "%") if params[:notes] || all
      @nodes += DrupalNode.limit(25)
                          .order("nid DESC")
                          .where('(type = "page" OR type = "place" OR type = "tool") AND node.status = 1 AND title LIKE ?', "%" + params[:id] + "%") if params[:wikis] || all
      @nodes += DrupalNode.limit(25)
                          .order("nid DESC")
                          .where('type = "map" AND node.status = 1 AND title LIKE ?', "%" + params[:id] + "%") if params[:maps] || all
      @nodes += DrupalComment.limit(25)
                             .order("nid DESC")
                             .where('status = 1 AND comment LIKE ?', "%" + params[:id] + "%") if params[:comments] || all
    end
  end

  # utility response to fill out search autocomplete
  # needs *dramatic* optimization
  def typeahead
    @match = SearchService.new.type_ahead(params[:id])
    render json: @match
  end

  def map
    @users = DrupalUsers.where("lat != 0.0 AND lon != 0.0")
  end

end
