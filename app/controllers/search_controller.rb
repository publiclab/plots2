class SearchController < ApplicationController

  def index
    @title = "Search"
    @nodes = DrupalNode.paginate(:order => "node.nid DESC", :conditions => ['type = "note" AND status = 1 AND (node.title LIKE ? OR node_revisions.body LIKE ?)', "%"+params[:id]+"%","%"+params[:id]+"%"], :page => params[:page], :include => :drupal_node_revision)
    @tagnames = params[:id].split(',')

    # content based on tags
    set_sidebar :tags, [params[:id]]

    render :template => 'search/index'
  end

  def advanced
    @title = "Advanced search"
    all = !params[:notes] && !params[:wikis] && !params[:maps] && !params[:comments]
    @nodes = []
    unless params[:id].nil?
      @nodes += DrupalNode.find(:all, :limit => 25, :order => "nid DESC", :conditions => ['type = "note" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"]) if params[:notes] || all
      @nodes += DrupalNode.find(:all, :limit => 25, :order => "nid DESC", :conditions => ['type = "page" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"]) if params[:wikis] || all
      @nodes += DrupalNode.find(:all, :limit => 25, :order => "nid DESC", :conditions => ['type = "map" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"]) if params[:maps] || all
      @nodes += DrupalComment.find(:all, :limit => 25, :order => "nid DESC", :conditions => ['status = 1 AND comment LIKE ?', "%"+params[:id]+"%"]) if params[:comments] || all
    end
  end

  # utility response to fill out search autocomplete
  # needs *dramatic* optimization
  def typeahead
    matches = []
    DrupalNode.find(:all, :limit => 5, :order => "nid DESC", :conditions => ['type = "note" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"], :select => "title,type,nid").each do |match|
      matches << {:string => "<i class='icon-file'></i> "+match.title, :url => "/"+match.slug}
    end
    DrupalNode.find(:all, :limit => 5, :order => "nid DESC", :conditions => ['type = "page" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"], :select => "title,type,nid").each do |match|
      matches << {:string => "<i class='icon-book'></i> "+match.title, :url => "/wiki/"+match.slug}
    end
    DrupalNode.find(:all, :limit => 5, :order => "nid DESC", :conditions => ['type = "map" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"], :select => "title,type,nid").each do |match|
      matches << {:string => "<i class='icon-map-marker'></i> "+match.title, :url => "/"+match.slug}
    end
    DrupalUsers.find(:all, :limit => 5, :order => "uid", :conditions => ['name LIKE ? AND access != 0', "%"+params[:id]+"%"]).each do |match|
      matches << {:string => "<i class='icon-user'></i> "+match.name, :url => "/notes/author/"+match.name}
    end
    render :json => matches
  end

  def map
    @users = DrupalUsers.find(:all, :conditions => ["lat != 0.0 AND lon != 0.0"])
  end

end
