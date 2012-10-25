class TagController < ApplicationController

  def tag
    if (@tag = DrupalTag.find_by_name(params[:id]))
      @nodes = @tag.nodes
      @tags = [@tag]
      @tagnames = @tags.collect(&:name)
      @wikis = DrupalTag.find_nodes_by_type(@tags,'page',10)
    else
      @nodes = []
      @tags = []
      @tagnames = []
      @wikis = []
    end
    @unpaginated = true
    render :template => "notes/index"
  end

end
