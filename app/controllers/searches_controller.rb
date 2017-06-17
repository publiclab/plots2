require 'search'

class SearchesController < ApplicationController
  include SolrToggle

  def test
    term = params[:q] || "Chicago"
    if solrAvailable
      @search = Node.search do
        fulltext term
      end
      render text: @search.results.to_json
    else
      render text: 'Solr search service offline'
    end
  end

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
    set_sidebar :tags, [params[:id]]

<<<<<<< cb9e547c568156167e82839f8f39fc129ec207ba
    @nodes = SearchService.new.nodes(params[:id])
=======
    @notes = SearchService.new.textSearch_notes(params[:id]).getDocs
>>>>>>> .getDocs
  end

end
