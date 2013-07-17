class TagController < ApplicationController

  respond_to :html, :xml, :json
  before_filter :require_user, :only => [:create, :delete]

  def show
    set_sidebar :tags, [params[:id]], {:note_count => 20}

    @tags = DrupalTag.find_all_by_name params[:id]
    @tagnames = @tags.collect(&:name).uniq! || []
    @title = @tagnames.join(', ') if @tagnames

    @unpaginated = true
  end

  def blog
    @wikis = DrupalTag.find_pages(params[:id],10)
    nids = DrupalTag.find_nodes_by_type(params[:id],'note',20).collect(&:nid)
    @notes = DrupalNode.paginate(:conditions => ['nid in (?)', nids], :order => "nid DESC", :page => params[:page])
    @tags = DrupalTag.find_all_by_name params[:id]
    @tagnames = @tags.collect(&:name).uniq! || []
    @title = @tagnames.join(',') + " Blog" if @tagnames
  end

  def author
    render :json => DrupalUsers.find_by_name(params[:id]).tag_counts
  end

  def create
    tagnames = params[:name].split(',')
    response = { :errors => [],
      :saved => [],
    }

    node = DrupalNode.find params[:nid]
    tagnames.each do |tagname|
      if DrupalTag.exists?(tagname,params[:nid])
        response[:errors] << "Error: that tag already exists."
      else 
        saved,tag = node.add_tag(tagname,current_user)
        if saved
          response[:saved] << [tag.name,tag.id]
        else
          response[:errors] << tag.errors[:name].first
        end
      end
    end
    respond_with do |format|
      format.html do
        if request.xhr?
          render :json => response
        else
          flash[:notice] = "#{response[:saved].length} tags created, #{response[:errors].length} errors."
          redirect_to node.path
        end
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
    suggestions = []
    DrupalTag.find(:all, :conditions => ['name LIKE ?', "%"+params[:id]+"%"], :limit => 10).each do |tag|
      suggestions << {:string => tag.name.downcase}
    end
    render :json => suggestions.uniq
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

  def contributors
    set_sidebar :tags, [params[:id]], {:note_count => 20}
    @tagnames = [params[:id]]
 
    t = DrupalTag.find :all, :conditions => {:name => params[:id]}
    nt = DrupalNodeTag.find :all, :conditions => ['tid in (?)',t.collect(&:tid)]
    nct = DrupalNodeCommunityTag.find :all, :conditions => ['tid in (?)',t.collect(&:tid)]
    @users = DrupalUsers.find :all, :conditions => ['uid IN (?)',(nt+nct).collect(&:uid)]
    @wikis = DrupalNode.find :all, :conditions => ["nid IN (?) AND (type = 'page' OR type = 'tool' OR type = 'place')", (nt+nct).collect(&:nid)]
    @notes = DrupalNode.find :all, :conditions => ["nid IN (?) AND type = 'note'", (nt+nct).collect(&:nid)]
  end

end
