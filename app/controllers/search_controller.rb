class SearchController < ApplicationController

  def index
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => ['type = "note" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"], :page => params[:page])
    @tags = [DrupalTag.find_by_name(params[:id])]
    @tagnames = @tags.collect(&:name)
    @wikis = DrupalTag.find_nodes_by_type(@tags,'page',10)
    @notes = DrupalTag.find_nodes_by_type(@tags,'note',10)
    render :template => 'notes/index'
  end

  # utility response to fill out search autocomplete
  def typeahead
    matches = []
    DrupalNode.find(:all, :limit => 10, :order => "nid DESC", :conditions => ['(type = "note" OR type = "wiki") AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"], :select => "title").each do |match|
      matches << match.title
    end
    render :json => '["'+matches.join('","')+'"]'
  end

end
