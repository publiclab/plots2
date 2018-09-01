require 'search'

class SearchesController < ApplicationController
  # Dynamic Search Page using pure JavaScript JSON RESTful API
  def dynamic
    render :dynamic
  end

  # /search/
  def new; end

  # results: /search/foo
  def results
    @title = 'Search'
    @tagnames = params[:id].split(',')
    @users = SearchService.new.find_users(params[:id], limit = 10)
    @nodes = SearchService.new.find_nodes(params[:id], 100, params[:order].to_s.to_sym)
      .paginate(page: params[:page], per_page: 24)
  end
end
