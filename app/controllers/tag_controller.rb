class TagController < ApplicationController

  respond_to :html, :xml, :json
  before_filter :require_user, :only => [:create, :delete]

  def show
    set_sidebar :tags, [params[:id]]

    @tags = DrupalTag.find_all_by_name params[:id]
    @tagnames = @tags.collect(&:name).uniq! || []
    @title = @tagnames.join(', ') if @tagnames

    @unpaginated = true
  end

  def author
    render :json => DrupalUsers.find_by_name(params[:id]).tag_counts
  end

  def create
    if DrupalTag.exists?(params[:tagname],params[:nid])
      render :text => "Error: that tag already exists."
    else 
      @node = DrupalNode.find params[:nid]
      saved,tag = @node.add_tag(params[:name],current_user)
      if saved
        respond_with do |format|
          format.html do
            if request.xhr?
              render :text => tag.name+','+tag.id.to_s
            else
              flash[:notice] = "Tag created."
              redirect_to @node.path
            end
          end
        end
      else
        render :text => "Error: Tags "+tag.errors[:name].first
      end
    end
  end

  # should delete only the term_node/node_tag (instance), not the term_data (class)
  def delete
    node_tag = DrupalNodeCommunityTag.find(:first,:conditions => {:nid => params[:nid], :tid => params[:tid]})
    # check for community tag too...
    if node_tag.uid == current_user.uid #|| current_user.role == "admin"
      node_tag.delete
      respond_with do |format|
        format.html do
          if request.xhr?
            render :text => node_tag.tid
          else
            flash[:notice] = "Tag deleted."
            redirect_to node_tag.node.path
          end
        end
      end
    else
      flash[:error] = "You must own the tag to delete it."
      redirect_to DrupalNode.find_by_nid(params[:nid]).path
    end
  end

  def suggested
    #params[:id]
    suggestions = []
    [
     'balloon-mapping',
     'kite-mapping',
     'near-infrared-camera',
     'thermal-photography',
     'spectrometer',
     'troubleshooting'
    ].each do |tagname|
      suggestions << {:string => tagname}
    end
    render :json => suggestions
  end

  def rss
    @notes = DrupalTag.find_nodes_by_type([params[:tagname]],'note',20)
    respond_to do |format|
      format.rss {
        render :layout => false
        response.headers["Content-Type"] = "application/xml; charset=utf-8"
      } 
    end
  end

end
