class TagController < ApplicationController

  respond_to :html, :xml, :json
  before_filter :require_user, :only => [:create, :delete]

  def show
    @node_type = params[:node_type] || "note"
      @node_type = "page" if @node_type == "wiki"
      @node_type = "map" if @node_type == "maps"
    if params[:id][-1..-1] == "*"
      @wildcard = true
      @tags = DrupalTag.find :all, :conditions => ['name LIKE (?)',params[:id][0..-2]+'%']
      nodes = DrupalNode.where(:status => 1, :type => @node_type).includes(:drupal_node_revision,:drupal_tag).where('term_data.name LIKE (?)',params[:id][0..-2]+'%').page(params[:page]).order("node_revisions.timestamp DESC")
    else
      @tags = DrupalTag.find_all_by_name params[:id]
      nodes = DrupalNode.where(:status => 1, :type => @node_type).includes(:drupal_node_revision,:drupal_tag).where('term_data.name = ?',params[:id]).page(params[:page]).order("node_revisions.timestamp DESC")
    end
      @notes = nodes if @node_type == "note"
      @wikis = nodes if @node_type == "page"
      @nodes = nodes if @node_type == "map"
    @title = params[:id]
    set_sidebar :tags, [params[:id]]
  end

  def widget
    num = params[:n] || 4
    nids = DrupalTag.find_nodes_by_type(params[:id],'note',num).collect(&:nid)
    @notes = DrupalNode.paginate(:conditions => ['status = 1 AND nid in (?)', nids], :order => "nid DESC", :page => params[:page])
    render :layout => false
  end

  def blog
    @wikis = DrupalTag.find_pages(params[:id],10)
    nids = DrupalTag.find_nodes_by_type(params[:id],'note',20).collect(&:nid)
    @notes = DrupalNode.paginate(:conditions => ['status = 1 AND nid in (?)', nids], :order => "nid DESC", :page => params[:page])
    @tags = DrupalTag.find_all_by_name params[:id]
    @tagnames = @tags.collect(&:name).uniq! || []
    @title = @tagnames.join(',') + " Blog" if @tagnames
  end

  def author
    render :json => DrupalUsers.find_by_name(params[:id]).tag_counts
  end

  def barnstar
    node = DrupalNode.find params[:nid]
    tagname = "barnstar:"+params[:star]
    if DrupalTag.exists?(tagname,params[:nid])
      flash[:error] = "Error: that tag already exists."
    elsif !node.add_tag(tagname.strip,current_user)
      flash[:error] = "The barnstar could not be created."
    else
      flash[:notice] = "You awarded the <a href='/wiki/barnstars#"+params[:star].split('-').each{|w| w.capitalize!}.join('+')+"+Barnstar'>"+params[:star]+" barnstar</a> to <a href='/profile/"+node.author.name+"'>"+node.author.name+"</a>"
    end
    redirect_to node.path
  end

  def create
    params[:name] ||= ""
    tagnames = params[:name].split(',')
    response = { :errors => [],
      :saved => [],
    }

    node = DrupalNode.find params[:nid]
    tagnames.each do |tagname|
      if DrupalTag.exists?(tagname,params[:nid])
        response[:errors] << "Error: that tag already exists."
      else 
        saved,tag = node.add_tag(tagname.strip,current_user)
        if saved
          response[:saved] << [tag.name,tag.id]
        else
          response[:errors] << "Error: tags "+tag.errors[:name].first
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
    if node_tag.uid == current_user.uid || current_user.role == "admin" || current_user.role == "moderator"

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
    if params[:tagname][-1..-1] == "*"
      @notes = DrupalNode.where(:status => 1, :type => 'note').includes(:drupal_node_revision,:drupal_tag).where('term_data.name LIKE (?)',params[:tagname][0..-2]+'%').limit(20).order("node_revisions.timestamp DESC")
    else
      @notes = DrupalTag.find_nodes_by_type([params[:tagname]],'note',20)
    end
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
    @tag = DrupalTag.find_by_name params[:id]
    @notes = DrupalNode.where(:status => 1, :type => 'note').includes(:drupal_node_revision,:drupal_tag).where('term_data.name = ?',params[:id]).order("node_revisions.timestamp DESC")
    @users = @notes.collect(&:author).uniq
  end

  # /contributors
  def contributors_index
    @tagnames = ['balloon-mapping','spectrometer','infragram','air-quality','water-quality']
    @tagdata = {}
    @tags = []

    @tagnames.each do |tagname|
      @tags << DrupalTag.find_by_name(tagname)

      # optimization:
      # consolidate: remove drupalNodeTag once that's collapsed, remove DrupalTag.find:all once consolidated
      @tagdata[tagname] = {}
      t = DrupalTag.find :all, :conditions => {:name => tagname}
      nt = DrupalNodeTag.find :all, :conditions => ['tid in (?)',t.collect(&:tid)]
      nct = DrupalNodeCommunityTag.find :all, :conditions => ['tid in (?)',t.collect(&:tid)]
      @tagdata[tagname][:users] = DrupalNode.find(:all, :conditions => ['nid IN (?)',(nt+nct).collect(&:nid)]).collect(&:author).uniq!.length
      @tagdata[tagname][:wikis] = DrupalNode.count :all, :conditions => ["nid IN (?) AND (type = 'page' OR type = 'tool' OR type = 'place')", (nt+nct).collect(&:nid)]
      @tagdata[:notes] = DrupalNode.count :all, :conditions => ["nid IN (?) AND type = 'note'", (nt+nct).collect(&:nid)]
    end
    render :template => "tag/contributors-index"
  end

end
