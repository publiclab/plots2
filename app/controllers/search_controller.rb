class SearchController < ApplicationController

  def index
    @title = "Search"
    @tagnames = params[:id].split(',')
    @users = DrupalUsers.find(:all, :limit => 5, :order => "uid", :conditions => ['name LIKE ? AND access != 0', "%"+params[:id]+"%"])
    set_sidebar :tags, [params[:id]]
    @notes = DrupalNode.paginate(:order => "node.nid DESC", :conditions => ['(type = "note" OR type = "page" OR type = "map") AND status = 1 AND (node.title LIKE ? OR node_revisions.title LIKE ? OR node_revisions.body LIKE ?)', "%"+params[:id]+"%","%"+params[:id]+"%","%"+params[:id]+"%"], :page => params[:page], :include => :drupal_node_revision, :page => params[:page])
    render :template => 'search/index'
  end

  def advanced
    @title = "Advanced search"
    all = !params[:notes] && !params[:wikis] && !params[:maps] && !params[:comments]
    @nodes = []
    unless params[:id].nil?
      @nodes += DrupalNode.find(:all, :limit => 25, :order => "nid DESC", :conditions => ['type = "note" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"]) if params[:notes] || all
      @nodes += DrupalNode.find(:all, :limit => 25, :order => "nid DESC", :conditions => ['(type = "page" OR type = "place" OR type = "tool") AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"]) if params[:wikis] || all
      @nodes += DrupalNode.find(:all, :limit => 25, :order => "nid DESC", :conditions => ['type = "map" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"]) if params[:maps] || all
      @nodes += DrupalComment.find(:all, :limit => 25, :order => "nid DESC", :conditions => ['status = 1 AND comment LIKE ?', "%"+params[:id]+"%"]) if params[:comments] || all
    end
  end

  # utility response to fill out search autocomplete
  # needs *dramatic* optimization
  def typeahead
    matches = []
    DrupalNode.find(:all, :limit => 5, :order => "nid DESC", :conditions => ['type = "note" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"], :select => "title,type,nid,path").each do |match|
      matches << "<i data-url='"+match.path+"' class='icon-file'></i> "+match.title
    end
    DrupalNode.find(:all, :limit => 5, :order => "nid DESC", :conditions => ['(type = "page" OR type = "place" OR type = "tool") AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"], :select => "title,type,nid,path").each do |match|
      matches << "<i data-url='"+match.path+"' class='icon-"+match.icon+"'></i> "+match.title
    end
    DrupalNode.find(:all, :limit => 5, :order => "nid DESC", :conditions => ['type = "map" AND status = 1 AND title LIKE ?', "%"+params[:id]+"%"], :select => "title,type,nid,path").each do |match|
      matches << "<i data-url='"+match.path+"' class='icon-"+match.icon+"'></i> "+match.title
    end
    DrupalUsers.find(:all, :limit => 5, :order => "uid", :conditions => ['name LIKE ? AND access != 0', "%"+params[:id]+"%"]).each do |match|
      matches << "<i data-url='/profile/"+match.name+"' class='icon-user'></i> "+match.name
    end
    DrupalTag.includes(:drupal_node).where('node.status = 1').limit(5).where('name LIKE ?', "%"+params[:id]+"%").each do |match|
      matches << "<i data-url='/tag/"+match.name+"' class='icon-tag'></i> "+match.name
    end
    render :json => matches
  end

  def map
    @users = DrupalUsers.find(:all, :conditions => ["lat != 0.0 AND lon != 0.0"])
  end

end
