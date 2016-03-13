class TagController < ApplicationController

  respond_to :html, :xml, :json, :ics
  before_filter :require_user, :only => [:create, :delete]

  def index
    @title = "Tags"
    @paginated = true
    @tags = DrupalTag.paginate(:page => params[:page])
                     .order('count DESC')
  end

  def show
    @node_type = params[:node_type] || "note"
      @node_type = "page" if @node_type == "wiki"
      @node_type = "map" if @node_type == "maps"
    if params[:id][-1..-1] == "*" # wildcard tags
      @wildcard = true
      @tags = DrupalTag.where('name LIKE (?)', params[:id][0..-2] + '%')
      nodes = DrupalNode.where(:status => 1, :type => @node_type)
                        .includes(:drupal_node_revision, :drupal_tag)
                        .where('term_data.name LIKE (?)', params[:id][0..-2] + '%')
                        .page(params[:page])
                        .order("node_revisions.timestamp DESC")
    else
      @tags = DrupalTag.find_all_by_name params[:id]
      nodes = DrupalNode.where(status: 1, type: @node_type)
                        .includes(:drupal_node_revision, :drupal_tag)
                        .where('term_data.name = ?', params[:id])
                        .page(params[:page])
                        .order("node_revisions.timestamp DESC")
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
    @notes = DrupalNode.page(params[:page])
                       .where('status = 1 AND nid in (?)', nids)
                       .order("nid DESC")
    render :layout => false
  end

  def blog
    nids = DrupalTag.find_nodes_by_type(params[:id],'note',20).collect(&:nid)
    @notes = DrupalNode.page(params[:page])
                       .where('status = 1 AND nid in (?)', nids)
                       .order("nid DESC")
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
    elsif !node.add_barnstar(tagname.strip,current_user)
      flash[:error] = "The barnstar could not be created."
    else
      flash[:notice] = "You awarded the <a href='/wiki/barnstars#"+params[:star].split('-').each{|w| w.capitalize!}.join('+')+"+Barnstar'>"+params[:star]+" barnstar</a> to <a href='/profile/"+node.author.name+"'>"+node.author.name+"</a>"
    end
    redirect_to node.path
  end

  def create
    params[:name] ||= ""
    tagnames = params[:name].split(',')
    @output = { :errors => [],
      :saved => [],
    }
    @tags = [] # not used except in tests for now

    node = DrupalNode.find params[:nid]
    tagnames.each do |tagname|

      # this should all be done in the model:

      if DrupalTag.exists?(tagname,params[:nid])
        @output[:errors] << "Error: that tag already exists."
      else 
        # "with:foo" coauthorship powertag: by author only
        if tagname[0..4] == "with:" && node.author.uid != current_user.uid
          @output[:errors] << "Error: only the author may use that powertag."
        # "with:foo" coauthorship powertag: only for real users
        elsif tagname[0..4] == "with:" && User.find_by_username(tagname.split(':')[1]).nil?
          @output[:errors] << "Error: cannot find that username."
        elsif tagname[0..4] == "with:" && tagname.split(':')[1] == current_user.username
          @output[:errors] << "Error: you cannot add yourself as coauthor."
        elsif tagname[0..4] == "rsvp:" && current_user.username != tagname.split(':')[1]
          @output[:errors] << "Error: you can only RSVP for yourself."
        else
          saved,tag = node.add_tag(tagname.strip,current_user)
          if saved
            @tags << tag
            @output[:saved] << [tag.name,tag.id]
          else
            @output[:errors] << "Error: tags "+tag.errors[:name].first
          end
        end
      end
    end
    respond_with do |format|
      format.html do
        if request.xhr?
          render :json => @output
        else
          flash[:notice] = "#{@output[:saved].length} tags created, #{@output[:errors].length} errors."
          redirect_to node.path
        end
      end
    end
  end

  # should delete only the term_node/node_tag (instance), not the term_data (class)
  def delete
    node_tag = DrupalNodeCommunityTag.where(nid: params[:nid], tid: params[:tid]).first
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
    if params[:id].length > 2
      suggestions = []
      # filtering out tag spam by requiring tags attached to a published node
      DrupalTag.where('name LIKE ?', "%" + params[:id] + "%")
               .includes(:drupal_node)
               .where('node.status = 1')
               .limit(10).each do |tag|
        suggestions << tag.name.downcase
      end
      render :json => suggestions.uniq
    else
      render :json => []
    end
  end

  def rss
    if params[:tagname][-1..-1] == "*"
      @notes = DrupalNode.where(:status => 1, :type => 'note')
                         .includes(:drupal_node_revision,:drupal_tag)
                         .where('term_data.name LIKE (?)', params[:tagname][0..-2]+'%')
                         .limit(20)
                         .order("node_revisions.timestamp DESC")
    else
      @notes = DrupalTag.find_nodes_by_type([params[:tagname]],'note',20)
    end
    respond_to do |format|
      format.rss {
        response.headers["Content-Type"] = "application/xml; charset=utf-8"
        render :layout => false
      } 
      format.ics {
        response.headers['Content-Disposition'] = "attachment; filename='public-lab-events.ics'"
        response.headers["Content-Type"] = "text/calendar; charset=utf-8"
        render :layout => false, :template => "tag/icalendar.ics", :filename => "public-lab-events.ics"
      } 
    end
  end

  def contributors
    set_sidebar :tags, [params[:id]], {:note_count => 20}
    @tagnames = [params[:id]]
    @tag = DrupalTag.find_by_name params[:id]
    @notes = DrupalNode.where(:status => 1, :type => 'note')
                       .includes(:drupal_node_revision,:drupal_tag)
                       .where('term_data.name = ?', params[:id])
                       .order("node_revisions.timestamp DESC")
    @users = @notes.collect(&:author).uniq
  end

  # /contributors
  def contributors_index
    @tagnames = ['balloon-mapping','spectrometer','infragram','air-quality','water-quality']
    @tagdata = {}
    @tags = []

    @tagnames.each do |tagname|
      tag = DrupalTag.find_by_name(tagname)
      @tags << tag if tag
      @tagdata[tagname] = {}
      t = DrupalTag.find :all, :conditions => {:name => tagname}
      nct = DrupalNodeCommunityTag.find :all, :conditions => ['tid in (?)',t.collect(&:tid)]
      @tagdata[tagname][:users] = DrupalNode.find(:all, :conditions => ['nid IN (?)',(nct).collect(&:nid)]).collect(&:author).uniq.length
      @tagdata[tagname][:wikis] = DrupalNode.count :all, :conditions => ["nid IN (?) AND (type = 'page' OR type = 'tool' OR type = 'place')", (nct).collect(&:nid)]
      @tagdata[:notes] = DrupalNode.count :all, :conditions => ["nid IN (?) AND type = 'note'", (nct).collect(&:nid)]
    end
    render :template => "tag/contributors-index"
  end

end
