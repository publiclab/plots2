class NotesController < ApplicationController

  def index
    @nodes = DrupalNode.paginate(:limit => 20, :order => "nid DESC", :conditions => {:type => 'note', :status => 1}, :page => params[:page])
  end

  def show
    @tags = ['balloon-mapping','somerville']
    @node = DrupalNode.find params[:id]
  end

  def author
    @nodes = DrupalNode.find :all, :limit => 20, :order => "nid DESC", :conditions => {:type => 'note', :status => 1, :author => params[:id]}
  end

end
