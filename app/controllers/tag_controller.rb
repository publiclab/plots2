class TagController < ApplicationController

  respond_to :html, :xml, :json, :ics
  before_filter :require_user, :only => [:create, :delete]

  def index
    @title = I18n.t('tag_controller.tags')
    @paginated = true
    @tags = Tag.joins(:drupal_node_community_tag, :node)
                     .where('node.status = ?', 1)
                     .paginate(:page => params[:page])
                     .order('count DESC')
                     .group(:name)
  end

  def show
    @wiki = Node.where(slug: params[:id]).first
    if params[:id].match('question:')
      default_type = "questions"
    else
      default_type = "note"
    end
    @node_type = params[:node_type] || default_type
    node_type = "note" if @node_type == "questions" || @node_type == "note"
    node_type = "page" if @node_type == "wiki"
    node_type = "map" if @node_type == "maps"
    qids = Node.questions.where(status: 1).collect(&:nid)
    if params[:id][-1..-1] == "*" # wildcard tags
      @wildcard = true
      @tags = Tag.where('name LIKE (?)', params[:id][0..-2] + '%')
      nodes = Node.where(status: 1, type: node_type)
                        .includes(:drupal_node_revision, :tag)
                        .where('term_data.name LIKE (?) OR term_data.parent LIKE (?)', params[:id][0..-2] + '%', params[:id][0..-2] + '%')
                        .page(params[:page])
                        .order("node_revisions.timestamp DESC")
    else
      @tags = Tag.find_all_by_name params[:id]
      nodes = Node.where(status: 1, type: node_type)
                        .includes(:drupal_node_revision, :tag)
                        .where('term_data.name = ? OR term_data.parent = ?', params[:id], params[:id])
                        .page(params[:page])
                        .order("node_revisions.timestamp DESC")
    end
    @notes = nodes.where('node.nid NOT IN (?)', qids) if @node_type == "note"
    @questions = nodes.where('node.nid IN (?)', qids) if @node_type == "questions"
    @wikis = nodes if @node_type == "wiki"
    @nodes = nodes if @node_type == "maps"
    @title = params[:id]
    set_sidebar :tags, [params[:id]]

    respond_with(nodes) do |format|
      format.html { render 'tag/show' }
      format.xml  { render xml: nodes }
      format.json  {
        json = []
        nodes.each do |node|
          json << node.as_json(except: [:path, :tags])
          json.last['path'] = "https://" + request.host.to_s + node.path
          json.last['preview'] = node.body_preview(500)
          json.last['image'] = node.main_image.path(:large) if node.main_image
          json.last['tags'] = Node.find(node.id).tags.collect(&:name) if node.tags
        end
        render json: json
      }
    end
  end
    
  def widget
    num = params[:n] || 4
    nids = Tag.find_nodes_by_type(params[:id],'note',num).collect(&:nid)
    @notes = Node.page(params[:page])
                       .where('status = 1 AND nid in (?)', nids)
                       .order("nid DESC")
    render :layout => false
  end

  def blog
    nids = Tag.find_nodes_by_type(params[:id],'note',20).collect(&:nid)
    @notes = Node.paginate(:page => params[:page], :per_page => 6)
                       .where('status = 1 AND nid in (?)', nids)
                       .order("nid DESC")
    @tags = Tag.find_all_by_name params[:id]
    @tagnames = @tags.collect(&:name).uniq! || []
    @title = @tagnames.join(',') + " Blog" if @tagnames
  end

  def author
    render :json => DrupalUsers.find_by_name(params[:id]).tag_counts
  end

  def barnstar
    node = Node.find params[:nid]
    tagname = "barnstar:"+params[:star]
    if Tag.exists?(tagname,params[:nid])
      flash[:error] = I18n.t('tag_controller.tag_already_exists')
    elsif !node.add_barnstar(tagname.strip,current_user)
      flash[:error] = I18n.t('tag_controller.barnstar_not_created')
    else
      flash[:notice] = I18n.t('tag_controller.barnstar_awarded', url1: "/wiki/barnstars#"+params[:star].split('-').each{|w| w.capitalize!}.join('+')+"+Barnstar", star: params[:star], url2: "/profile/"+node.author.name, awardee: node.author.name).html_safe
      # on success add comment
      barnstar_info_link = '<a href="//' + request.host.to_s + '/wiki/barnstars">barnstar</a>'
      node.add_comment({
        subject: 'barnstar',
        uid: current_user.uid,
        body: "@#{current_user.username} awards a #{barnstar_info_link} to #{node.drupal_users.name} for their awesome contribution!"
      })
    end
    redirect_to node.path + "?_=" + Time.now.to_i.to_s
  end

  def create
    params[:name] ||= ""
    tagnames = params[:name].split(',')
    @output = {
      errors: [],
      saved: []
    }
    @tags = [] # not used except in tests for now

    node = Node.find params[:nid]
    tagnames.each do |tagname|

      # this should all be done in the model:

      if Tag.exists?(tagname, params[:nid])
        @output[:errors] << I18n.t('tag_controller.tag_already_exists')
      elsif node.can_tag(tagname, current_user) === true || current_user.role == "admin"# || current_user.role == "moderator"
        saved, tag = node.add_tag(tagname.strip, current_user)
        if saved
          @tags << tag
          @output[:saved] << [tag.name, tag.id]
        else
          @output[:errors] << I18n.t('tag_controller.error_tags') + tag.errors[:name].first
        end
      else
        @output[:errors] << node.can_tag(tagname, current_user, true)
      end
    end
    respond_with do |format|
      format.html do
        if request.xhr?
          render :json => @output
        else
          flash[:notice] = I18n.t('tag_controller.tags_created_error',
                                  tag_count: @output[:saved].length,
                                  error_count: @output[:errors].length
                           ).html_safe
          redirect_to node.path
        end
      end
    end
  end

  # should delete only the term_node/node_tag (instance), not the term_data (class)
  def delete
    node_tag = DrupalNodeCommunityTag.where(nid: params[:nid], tid: params[:tid]).first
    # only admins, mods, and tag authors can delete other peoples' tags
    if node_tag.uid == current_user.uid || current_user.role == "admin" || current_user.role == "moderator"

      node_tag.delete
      respond_with do |format|
        format.html do
          if request.xhr?
            render :text => node_tag.tid
          else
            flash[:notice] = I18n.t('tag_controller.tag_deleted')
            redirect_to node_tag.node.path
          end
        end
      end
    else
      flash[:error] = I18n.t('tag_controller.must_own_tag_to_delete')
      redirect_to Node.find_by_nid(params[:nid]).path
    end
  end

  def suggested
    if params[:id].length > 2
      @suggestions = []
      # filtering out tag spam by requiring tags attached to a published node
      Tag.where('name LIKE ?', "%" + params[:id] + "%")
               .includes(:node)
               .where('node.status = 1')
               .limit(10).each do |tag|
        @suggestions << tag.name.downcase
      end
      render :json => @suggestions.uniq
    else
      render :json => []
    end
  end

  def rss
    if params[:tagname][-1..-1] == "*"
      @notes = Node.where(:status => 1, :type => 'note')
                         .includes(:drupal_node_revision,:tag)
                         .where('term_data.name LIKE (?)', params[:tagname][0..-2]+'%')
                         .limit(20)
                         .order("node_revisions.timestamp DESC")
    else
      @notes = Tag.find_nodes_by_type([params[:tagname]],'note',20)
    end
    respond_to do |format|
      format.rss {
        response.headers["Content-Type"] = "application/xml; charset=utf-8"
        response.headers["Access-Control-Allow-Origin"] = "*"
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
    @tag = Tag.find_by_name params[:id]
    @notes = Node.where(:status => 1, :type => 'note')
                       .includes(:drupal_node_revision,:tag)
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
      tag = Tag.find_by_name(tagname)
      @tags << tag if tag
      @tagdata[tagname] = {}
      t = Tag.find :all, :conditions => {:name => tagname}
      nct = DrupalNodeCommunityTag.find :all, :conditions => ['tid in (?)',t.collect(&:tid)]
      @tagdata[tagname][:users] = Node.find(:all, :conditions => ['nid IN (?)',(nct).collect(&:nid)]).collect(&:author).uniq.length
      @tagdata[tagname][:wikis] = Node.count :all, :conditions => ["nid IN (?) AND (type = 'page' OR type = 'tool' OR type = 'place')", (nct).collect(&:nid)]
      @tagdata[:notes] = Node.count :all, :conditions => ["nid IN (?) AND type = 'note'", (nct).collect(&:nid)]
    end
    render :template => "tag/contributors-index"
  end

  # let's not use session for tags storage; deprecate these unless they're being used
  # to remember and persist recently searched for tags:
  def add_tag
    unless session[:tags]
      session[:tags] = {}
    end
    tagnames = params[:name].split(',')
    tagnames.each do |tagname|
      tag = Tag.find_by_name(tagname)
      if tag
        session[:tags][tag.tid.to_s] = tagname
      else
        session[:tags][tagname] = tagname
      end
    end
    redirect_to params[:return_to]
  end

  def remove_tag
    if session[:tags]
      session[:tags].delete(params[:id])
    end
    redirect_to params[:return_to]
  end

  def remove_all_tags
    if session[:tags]
      session[:tags].clear
    end
    redirect_to params[:return_to]
  end

  def location
    render template: 'locations/_form'
  end

  def gridsEmbed
    render layout: false
  end

end
