class SearchController < ApplicationController

  def index
    @nodes = DrupalNode.paginate(:limit => 20, :order => "nid DESC", :conditions => ['type = "note" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"], :page => params[:page])
    @wikis = DrupalNode.paginate(:limit => 20, :order => "nid DESC", :conditions => ['type = "wiki" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"], :page => params[:page])
    render :template => 'notes/index'
  end

end
