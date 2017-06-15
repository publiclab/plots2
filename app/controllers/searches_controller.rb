require 'search'

class SearchesController < ApplicationController
  include SolrToggle

  def test
    term = params[:q] || "Chicago"
    if solrAvailable
      @search = Node.search do
        fulltext term do 
          fields(:title, :body) # can later add username, other fields, comments, maybe tags
        end
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
    @users = @search_service.users(params[:id])
    set_sidebar :tags, [params[:id]]

    # Adapt to SearchService:
    @notes = Node.paginate(page: params[:page])
                 .order('node.nid DESC')
                 .where('(type = "note" OR type = "page" OR type = "map") AND node.status = 1 AND (node.title LIKE ? OR node_revisions.title LIKE ? OR node_revisions.body LIKE ?)', '%' + params[:id] + '%', '%' + params[:id] + '%', '%' + params[:id] + '%')
                 .includes(:drupal_node_revision)
  end

end
