class NotesController < ApplicationController

  def index
    @title = "Research notes"
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'note', :status => 1}, :page => params[:page], :limit => 20)
    @wikis = DrupalNode.find(:all, :order => "changed DESC", :conditions => {:status => 1, :type => 'page'}, :limit => 10)
  end

  def show
    if params[:author] && params[:date]
      @node = DrupalUrlAlias.find_by_dst('notes/'+params[:author]+'/'+params[:date]+'/'+params[:id]).node 
    else
      @node = DrupalNode.find params[:id]
    end
    @node.view
    @title = @node.title
    @tags = @node.tags
    @tagnames = @tags.collect(&:name)
    @wikis = DrupalTag.find_nodes_by_type(@tagnames,'page',6)
    @notes = DrupalTag.find_nodes_by_type(@tagnames,'note',6)
  end

  def create

    # save main image
    if params[:node_images]
      params[:node_images].split(',').each do |id|
        img = Image.find id
        img.nid = @node.id
      end
    end
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
