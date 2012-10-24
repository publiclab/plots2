class SearchController < ApplicationController

  def index
    @nodes = DrupalNode.paginate(:limit => 20, :order => "nid DESC", :conditions => ['type = "note" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"], :page => params[:page])
    @wikis = DrupalNode.paginate(:limit => 20, :order => "nid DESC", :conditions => ['type = "wiki" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"], :page => params[:page])
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
