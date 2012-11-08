class SearchController < ApplicationController

  def index
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => ['type = "note" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"], :page => params[:page])
    @tags = [DrupalTag.find_by_name(params[:id])]
    @tagnames = @tags.collect(&:name)
    @wikis = DrupalTag.find_nodes_by_type(@tags,'page',10)
    @notes = DrupalTag.find_nodes_by_type(@tags,'note',10)
    render :template => 'notes/index'
  end

  def advanced
    all = !params[:notes] && !params[:wikis] && !params[:maps] && !params[:comments]
    @nodes = []
    @nodes += DrupalNode.find(:all, :limit => 25, :order => "nid DESC", :conditions => ['type = "note" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"]) if params[:notes] || all
    @nodes += DrupalNode.find(:all, :limit => 25, :order => "nid DESC", :conditions => ['type = "page" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"]) if params[:wikis] || all
    @nodes += DrupalNode.find(:all, :limit => 25, :order => "nid DESC", :conditions => ['type = "map" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"]) if params[:maps] || all
    @nodes += DrupalComment.find(:all, :limit => 25, :order => "nid DESC", :conditions => ['status = 1 AND comment LIKE ?', "%"+params[:id]+"%"]) if params[:comments] || all
  end

  # utility response to fill out search autocomplete
  def typeahead
    matches = []
    DrupalNode.find(:all, :limit => 15, :order => "nid DESC", :conditions => ['type = "note" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"], :select => "title").each do |match|
      matches << "<i class='icon-file'></i> "+match.title
    end
    DrupalNode.find(:all, :limit => 15, :order => "nid DESC", :conditions => ['type = "page" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"], :select => "title").each do |match|
      matches << "<i class='icon-book'></i> "+match.title
    end
    DrupalNode.find(:all, :limit => 15, :order => "nid DESC", :conditions => ['type = "map" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"], :select => "title").each do |match|
      matches << "<i class='icon-map-marker'></i> "+match.title
    end
    render :json => '["'+matches.join('","')+'"]'
  end

end
