module API
  class Typeahead < Grape::API
    
    before_filter :set_search_service

    resource :typeahead do

      # Request URL should be /api/typeahead/general/:id
      # Basic implementation from classic plots2 SearchController
      get :general do
        match = @search_service.type_ahead(params[:id])
        { sresult: match }
      end
    end

  private
    def set_search_service
      @search_service = SearchService.new
    end

    def search_params
      params.require(:search).permit(:comments, :maps, :wikis, :@notes)
    end
  end
end
