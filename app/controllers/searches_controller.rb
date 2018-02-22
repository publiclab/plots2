require 'search'

class SearchesController < ApplicationController

  # Dynamic Search Page using pure JavaScript JSON RESTful API
  def dynamic
    render :dynamic
  end

  # /search/
  def new
  end

  # results: /search/foo
  def results
    @title = 'Search'
    @tagnames = params[:id].split(',')
    @users = SearchService.new.users(params[:id])
    @nodes = SearchService.new.nodes(params[:id])
                              .paginate(page: params[:page], per_page: 24)
  end

end
