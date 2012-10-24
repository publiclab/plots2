class NotesController < ApplicationController

  def index
    @nodes = DrupalNode.paginate(:limit => 20, :order => "nid DESC", :conditions => {:type => 'note', :status => 1}, :page => params[:page])
  end

  def show
    @tags = ['balloon-mapping','somerville']
    @node = DrupalNode.find params[:id]
  end

  def author
    @user = DrupalUsers.find_by_name params[:id]
    @nodes = DrupalNode.paginate(:limit => 20, :order => "nid DESC", :conditions => {:type => 'note', :status => 1, :uid => @user.uid}, :page => params[:page])
    render :template => 'notes/index'
  end

end
