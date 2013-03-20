class TagController < ApplicationController

  def tag
    if (@tag = DrupalTag.find_by_name(params[:id]))
      @nodes = DrupalTag.find_nodes_by_type([@tag],'note',8)
      @tags = [@tag]
      @tagnames = @tags.collect(&:name)
      @wikis = DrupalTag.find_nodes_by_type(@tags,'page',10)
    end
    @tagnames ||= []
    @title = @tagnames.join(', ')
    @unpaginated = true
    render :template => "tag/tag"
  end

  def author
    render :json => DrupalUsers.find_by_name(params[:id]).tag_counts
  end

  # this is all silly and should be tucked into the model once we migrate away from Drupal
  def create
    if current_user
      @node = DrupalNode.find params[:nid]
      tag = DrupalTag.new({
        :vid => 1, # vocabulary id; 1
        :name => params[:name],
        :description => "",
        :weight => 0
      })
      tag.save
      node_tag = DrupalNodeTag.new({
        :tid => tag.id,
        :vid => 1,
        :nid => params[:nid]
      })
      node_tag.save
      flash[:notice] = "Tag created."
      redirect_to @node.slug
    else
      prompt_login "You must be logged in to tag."
    end
  end

  # should delete only the term_node/node_tag (instance), not the term_data (class)
  def delete
    if current_user
      tag = DrupalTag.find_by_name params[:name]
      DrupalNodeTag.find_by_nid(params[:nid], :conditions => {:tid => tag.tid}).delete
    else
      prompt_login "You must be logged in to delete tags."
    end
  end

end
