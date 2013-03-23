class NotesController < ApplicationController

  def index
    @title = "Research notes"
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'note', :status => 1}, :page => params[:page], :limit => 40)
  end

  def show
    @node = DrupalUrlAlias.find_by_dst('notes/'+params[:author]+'/'+params[:date]+'/'+params[:id]).node
    @node.view
    @title = @node.title
    @tags = @node.tags
    @tagnames = @tags.collect(&:name)
    @wikis = DrupalTag.find_nodes_by_type(@tags,'page',6)
    @notes = DrupalTag.find_nodes_by_type(@tags,'note',6)
  end

  def author
    @user = DrupalUsers.find_by_name params[:id]
    @title = @user.name
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'note', :status => 1, :uid => @user.uid}, :page => params[:page])
    render :template => 'notes/index'
  end

  def author_topic
    @user = DrupalUsers.find_by_name params[:author]
    @tagnames = params[:topic].split('+')
    @title = @user.name+" on '"+@tagnames.join(',')+"'"
    @nodes = @user.notes_for_tags(@tagnames)
    @unpaginated = true
    render :template => 'notes/index'
  end

end
