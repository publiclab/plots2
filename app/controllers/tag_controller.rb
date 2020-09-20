class TagController < ApplicationController
  respond_to :html, :xml, :json, :ics
  before_action :require_user, only: %i(create delete add_parent)
  include Pagy::Backend

  def index
    @toggle = params[:sort] || "uses"

    @title = I18n.t('tag_controller.tags')
    @paginated = true
    @order_type = params[:order] == "desc" ? "asc" : "desc"
    powertag_clause = params[:powertags] == 'true' ? '' : ['name NOT LIKE ?', '%:%']

    if params[:search]
      keyword = params[:search]
      @tags = Tag.joins(:node_tag, :node)
        .select('node.nid, node.status, term_data.*, community_tags.*')
        .where('node.status = ?', 1)
        .where('community_tags.date > ?', (DateTime.now - 1.month).to_i)
        .where("name LIKE :keyword", keyword: "%#{keyword}%")
        .where(powertag_clause)
        .group(:name)
        .order(order_string)
        .paginate(page: params[:page], per_page: 24)
    elsif @toggle == "uses"
      @tags = Tag.joins(:node_tag, :node)
        .select('node.nid, node.status, term_data.*, community_tags.*')
        .where('node.status = ?', 1)
        .where('community_tags.date > ?', (DateTime.now - 1.month).to_i)
        .where(powertag_clause)
        .group(:name)
        .order(order_string)
        .paginate(page: params[:page], per_page: 24)
    elsif @toggle == "name"
      @tags = Tag.joins(:node_tag, :node)
        .select('node.nid, node.status, term_data.*, community_tags.*')
        .where('node.status = ?', 1)
        .where('community_tags.date > ?', (DateTime.now - 1.month).to_i)
        .where(powertag_clause)
        .group(:name)
        .order(order_string)
        .paginate(page: params[:page], per_page: 24)
    elsif @toggle == "followers"
      raw_tags = Tag.joins(:node_tag, :node)
        .select('node.nid, node.status, term_data.*, community_tags.*')
        .where('node.status = ?', 1)
        .where('community_tags.date > ?', (DateTime.now - 1.month).to_i)
        .where(powertag_clause)
        .group(:name)
      raw_tags = Tag.sort_according_to_followers(raw_tags, params[:order])
      @tags = raw_tags.paginate(page: params[:page], per_page: 24)
    else
      tags = Tag.joins(:node_tag, :node)
        .select('node.nid, node.status, term_data.*, community_tags.*')
        .where('node.status = ?', 1)
        .where('community_tags.date > ?', (DateTime.now - 1.month).to_i)
        .where(powertag_clause)
        .group(:name)
        .order(order_string)

      followed = []
      not_followed = []
      tags.each do |tag|
        if current_user.following(tag.name) == true
          followed.append(tag.tid)
        else
          not_followed.append(tag.tid)
        end
      end

      ids = followed + not_followed
      @tags = Tag.where(tid: ids).sort_by { |p| ids.index(p.tid) }.paginate(page: params[:page], per_page: 24)
    end
  end

  def show
    if params[:id].is_a? Integer
      @wiki = Node.find(params[:id])&.first
    else
      @wiki = Node.where(path: "/wiki/#{params[:id]}").try(:first) || Node.where(path: "/#{params[:id]}").try(:first)
      @wiki = Node.where(slug: @wiki.power_tag('redirect'))&.first if @wiki&.has_power_tag('redirect') # use a redirected wiki page if it exists
    end
    @node = @wiki # expose the wiki node in the @node variable so we get open graph meta tags in the layout

    default_type = params[:id].match?('question:') ? 'questions' : 'note'
    if params[:order].nil?
      params[:order] = 'last_updated' # default ordering set
    end

    @node_type = params[:node_type] || default_type
    @start = Time.parse(params[:start]) if params[:start]
    @end = Time.parse(params[:end]) if params[:end]

    order_by =  if params[:order] == 'views'
                  'node.views DESC'
                elsif params[:order] == 'likes'
                  'node.cached_likes DESC'
                elsif params[:order] == 'last_updated'
                  'node_revisions.timestamp DESC'
                end

    node_type = if %w(questions note).include?(@node_type)
                  'note'
                elsif @node_type == 'wiki'
                  'page'
                elsif @node_type == 'maps'
                  'map'
                elsif @node_type == 'contributors'
                  'contributor'
                end

    if params[:id][-1..-1] == '*' # wildcard tags
      @wildcard = true
      @tags = Tag.where('name LIKE (?)', params[:id][0..-2] + '%')
      nodes = Node.for_tagname_and_type(params[:id], node_type, wildcard: true)
    else
      @tags = Tag.where(name: params[:id])
      nodes = Node.for_tagname_and_type(params[:id], node_type, question: (@node_type == 'questions'))
    end

    if @start && @end
      nodes = nodes.where(created: @start.to_i..@end.to_i)
    else
      @pinned_nodes = NodeShared.pinned_nodes(params[:id])
      if @pinned_nodes.size.positive? && params[:page].nil? # i.e. first page
        nodes = nodes.where.not(nid: @pinned_nodes.collect(&:id))
      end
    end

    @pagy, nodes = pagy(nodes.order(order_by), items: 24)
    @paginated = true

    @qids = Node.questions.where(status: 1)
               .collect(&:nid)
    if @qids.empty?
      @notes = nodes
      @questions = []
    else
      @notes = nodes.where('node.nid NOT IN (?)', @qids) if @node_type == 'note'
      @questions = nodes.where('node.nid IN (?)', @qids) if @node_type == 'questions'
    end

    @answered_questions = []
    @questions&.each { |question| @answered_questions << question if question.answers.any?(&:accepted) } # TODO: remove this upon refactor to remove answers code
    @wikis = nodes if @node_type == 'wiki'
    @wikis ||= []
    @nodes = nodes if @node_type == 'maps'
    @title = params[:id]

    @length = Tag.contributor_count(params[:id]) || 0

    @tagnames = [params[:id]]
    @tag = Tag.find_by(name: params[:id])
    @note_count = Tag.tagged_node_count(params[:id]) || 0
    @users = Tag.contributors(@tagnames[0])
    @related_tags = Tag.related(@tagnames[0])

    fetch_counts

    respond_with(nodes) do |format|
      format.html { render 'tag/show' }
      format.xml  { render xml: nodes }
      format.json do
        json = []
        nodes.each do |node|
          json << node.as_json(except: %i(path tags))
          json.last['path'] = 'https://' + request.host.to_s + node.path
          json.last['preview'] = node.body_preview(500)
          json.last['image'] = node.main_image.path(:large) if node.main_image
          json.last['tags'] = Node.find(node.id).tags.collect(&:name) if node.tags
        end
        render json: json
      end
    end
  end

  def show_for_author
    # try for a matching /wiki/_TAGNAME_ or /_TAGNAME_
    @wiki = Node.where(path: "/wiki/#{params[:id]}").try(:first) || Node.where(path: "/#{params[:id]}").try(:first)
    @wiki = Node.find(@wiki.power_tag('redirect')) if @wiki&.has_power_tag('redirect')

    default_type = if params[:id].match?('question:')
                     'questions'
                   else
                     'note'
                  end

    # params[:node_type] - this is an optional param
    # if params[:node_type] is nil - use @default_type
    @node_type = params[:node_type] || default_type

    node_type = 'note' if @node_type == 'questions' || @node_type == 'note'
    node_type = 'page' if @node_type == 'wiki'
    node_type = 'map' if @node_type == 'maps'
    qids = Node.questions.where(status: 1).collect(&:nid)

    if params[:id][-1..-1] == '*' # wildcard tags
      @wildcard = true
      @tags = Tag.where('name LIKE (?)', params[:id][0..-2] + '%')
    else
      @tags = Tag.where(name: params[:id])
    end
    @tagname = params[:id]
    @user = User.find_by(name: params[:author])

    nodes = Tag.tagged_nodes_by_author(@tagname, @user)
      .where(status: 1, type: node_type)
    @total_posts = nodes.size

    nodes = nodes.paginate(page: params[:page], per_page: 24)

    @notes ||= []

    @notes = nodes.where('node.nid NOT IN (?)', qids) if @node_type == 'note'
    @questions = nodes.where('node.nid IN (?)', qids) if @node_type == 'questions'
    ans_ques = Answer.where(uid: @user.id, accepted: true).includes(:node).map(&:node)
    @answered_questions = ans_ques.paginate(page: params[:page], per_page: 24)
    @wikis = nodes if @node_type == 'wiki'
    @nodes = nodes if @node_type == 'maps'
    @title = "'" + @tagname.to_s + "' by " + params[:author]

    @length = Tag.contributor_count(params[:id]) || 0
    respond_with(nodes) do |format|
      format.html { render 'tag/show' }
      format.xml  { render xml: nodes }
      format.json do
        json = []
        nodes.each do |node|
          json << node.as_json(except: %i(path tags))
          json.last['path'] = 'https://' + request.host
            .to_s + node.path
          json.last['preview'] = node.body_preview(500)
          json.last['image'] = node.main_image.path(:large) if node.main_image
          json.last['tags'] = Node.find(node.id).tags.collect(&:name) if node.tags
        end
        render json: json
      end
    end
  end

  def related
    @tags = Tag.related(params[:id])
    render partial: 'tag/related', layout: false, locals: { tags: @tags }
  end

  def widget
    num = params[:n] || 4
    nids = Tag.find_nodes_by_type(params[:id], 'note', num).collect(&:nid)
    @notes = Node.paginate(page: params[:page], per_page: 24)
      .where('status = 1 AND nid in (?)', nids)
      .order('nid DESC')
    render layout: false
  end

  def blog
    nids = Tag.find_nodes_by_type(params[:id], 'note', nil).collect(&:nid)
    @notes = Node.paginate(page: params[:page], per_page: 6)
      .where('status = 1 AND nid in (?)', nids)
      .order('created DESC')
    @tags = Tag.where(name: params[:id])
    @tagnames = @tags.collect(&:name).uniq! || []
    @title = @tagnames.join(',') + ' Blog' if @tagnames
  end

  def author
    render json: User.find_by(name: params[:id]).tag_counts
  end

  def barnstar
    node = Node.find params[:nid]
    tagname = 'barnstar:' + params[:star]
    if Tag.exists?(tagname, params[:nid])
      flash[:error] = I18n.t('tag_controller.tag_already_exists')
    elsif !node.add_barnstar(tagname.strip, current_user)
      flash[:error] = I18n.t('tag_controller.barnstar_not_created')
    else
      flash[:notice] = I18n.t('tag_controller.barnstar_awarded', url1: '/wiki/barnstars#' + params[:star].split('-').each(&:capitalize!).join('+') + '+Barnstar', star: params[:star], url2: '/profile/' + node.author.name, awardee: node.author.name).html_safe
      # on success add comment
      barnstar_info_link = '<a href="//' + request.host.to_s + '/wiki/barnstars">barnstar</a>'
      node.add_comment(subject: 'barnstar',
                       uid: current_user.uid,
                       body: "@#{current_user.username} awards a #{barnstar_info_link} to #{node.user.name} for their awesome contribution!")
    end
    redirect_to node.path + '?_=' + Time.now.to_i.to_s
  end

  def create
    params[:name] ||= ''
    tagnames = params[:name].split(',')
    @output = {
      errors: [],
      saved: []
    }
    @tags = [] # not used except in tests for now

    nid = params[:nid] || params[:id]
    node = Node.find nid
    tagnames.each do |tagname|
      # this should all be done in the model:
      tagname = tagname.strip
      if Tag.exists?(tagname, nid)
        @output[:errors] << I18n.t('tag_controller.tag_already_exists')

      elsif tagname.include?(":") && tagname.split(':').size < 2
        if tagname.split(':')[0] == "barnstar" || tagname.split(':')[0] == "with"
          @output[:errors] << I18n.t('tag_controller.cant_be_empty')
        end

      elsif node.can_tag(tagname, current_user) === true || logged_in_as(['admin'])
        saved, tag = node.add_tag(tagname.strip, current_user)
        if tagname.include?(":") && tagname.split(':').size == 2
          if tagname.split(':')[0] == "barnstar"
            CommentMailer.notify_barnstar(current_user, node)
            barnstar_info_link = '<a href="//' + request.host.to_s + '/wiki/barnstars">barnstar</a>'
            node.add_comment(subject: 'barnstar',
                             uid: current_user.uid,
                             body: "@#{current_user.username} awards a #{barnstar_info_link} to #{node.user.name} for their awesome contribution!")

          elsif tagname.split(':')[0] == "with"
            user = User.find_by_username_case_insensitive(tagname.split(':')[1])
            CommentMailer.notify_coauthor(user, node)
            node.add_comment(subject: 'co-author',
                             uid: current_user.uid,
                             body: " @#{current_user.username} has marked @#{tagname.split(':')[1]} as a co-author. ")

          end
        end

        if saved
          @tags << tag
          @output[:saved] << [tag.name, tag.id, nid]
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
          render json: @output
        else
          flash[:notice] = I18n.t('tag_controller.tags_created_error',
            tag_count: @output[:saved].size,
            error_count: @output[:errors].size).html_safe
          redirect_to node.path
        end
      end
    end
  end

  # should delete only the term_node/node_tag (instance), not the term_data (class)
  def delete
    node_tag = NodeTag.where(nid: params[:nid], tid: params[:tid]).first
    node = Node.where(nid: params[:nid]).first
    # only admins, mods, and tag authors can delete other peoples' tags
    if node_tag.uid == current_user.uid || logged_in_as(['admin', 'moderator']) || node.uid == current_user.uid

      tag = Tag.joins(:node_tag)
                   .select('term_data.name')
                   .where(tid: params[:tid])
                   .first

      if (tag.name.split(':')[0] == "lat") || (tag.name.split(':')[0] == "lon")
        node.delete_coord_attribute(tag.name)
      end

      node_tag.delete
      output = {
        status: true,
        tid: node_tag.tid
      }
      respond_with do |format|
        format.html do
          if request.xhr?
            render json: output
          else
            flash[:notice] = I18n.t('tag_controller.tag_deleted')
            redirect_to node_tag.node.path
          end
        end
      end
    else
      flash[:error] = I18n.t('tag_controller.must_own_tag_to_delete')
      redirect_to Node.find_by(nid: params[:nid]).path
    end
  end

  def suggested
    if !params[:id].empty? && params[:id].size > 2
      @suggestions = SearchService.new.search_tags(params[:id])
      render json: @suggestions.collect { |tag| tag.name }.uniq
    else
      render json: []
    end
  end

  def rss
    @notes = if params[:tagname][-1..-1] == '*'
               Node.where(status: 1, type: 'note')
                 .includes(:revision, :tag)
                 .references(:term_data, :node_revisions)
                 .where('term_data.name LIKE (?)', params[:tagname][0..-2] + '%')
                 .limit(20)
                 .order('node_revisions.timestamp DESC')
             else
               Tag.find_nodes_by_type([params[:tagname]], 'note', 20)
             end
    respond_to do |format|
      format.rss do
        response.headers['Content-Type'] = 'application/xml; charset=utf-8'
        response.headers['Access-Control-Allow-Origin'] = '*'
        render layout: false
      end
      format.ics do
        response.headers['Content-Disposition'] = "attachment; filename='public-lab-events.ics'"
        response.headers['Content-Type'] = 'text/calendar; charset=utf-8'
        render layout: false, template: 'tag/icalendar.ics', filename: 'public-lab-events.ics'
      end
    end
  end

  def rss_for_tagged_with_author
    @user = User.find_by(name: params[:authorname])
    @notes = Tag.tagged_nodes_by_author(params[:tagname], @user)
      .where(status: 1)
      .limit(20)
    respond_to do |format|
      format.rss do
        response.headers['Content-Type'] = 'application/xml; charset=utf-8'
        response.headers['Access-Control-Allow-Origin'] = '*'
        render layout: false
      end
      format.ics do
        response.headers['Content-Disposition'] = "attachment; filename='public-lab-events.ics'"
        response.headers['Content-Type'] = 'text/calendar; charset=utf-8'
        render layout: false, template: 'tag/icalendar.ics', filename: 'public-lab-events.ics'
      end
    end
  end

  def contributors
    set_sidebar :tags, [params[:id]], note_count: 20
    @tagnames = [params[:id]]
    @tag = Tag.find_by(name: params[:id])
    @note_count = Tag.tagged_node_count(params[:id]) || 0
    @users = Tag.contributors(@tagnames[0])
  end

  # /contributors
  def contributors_index
    @tagnames = ['balloon-mapping', 'spectrometer', 'infragram', 'air-quality', 'water-quality']
    @tagdata = {}
    @tags = []

    @tagnames.each do |tagname|
      tag = Tag.find_by(name: tagname)
      @tags << tag if tag
      @tagdata[tagname] = {}
      t = Tag.where(name: tagname)
      nct = NodeTag.where('tid in (?)', t.collect(&:tid))
      @tagdata[tagname][:users] = Node.where('nid IN (?)', nct.collect(&:nid)).collect(&:author).uniq.size
      @tagdata[tagname][:wikis] = Node.where("nid IN (?) AND (type = 'page' OR type = 'tool' OR type = 'place')", nct.collect(&:nid)).size
      @tagdata[:notes] = Node.where("nid IN (?) AND type = 'note'", nct.collect(&:nid)).size
    end
    render template: 'tag/contributors-index'
  end

  def add_parent
    if logged_in_as(['admin'])
      @tag = Tag.find_by(name: params[:name])
      @tag.update_attribute('parent', params[:parent])
      if @tag.save
        flash[:notice] = "Tag parent added."
      else
        flash[:error] = "There was an error adding a tag parent."
      end
      redirect_to '/tag/' + @tag.name + '?_=' + Time.now.to_i.to_s
    else
      flash[:error] = "Only admins may add tag parents."
    end
  end

  def location
    render template: 'locations/_form'
  end

  def location_modal
    render template: 'locations/_modal', layout: false
  end

  def gridsEmbed
    if %w(nodes wikis activities questions upgrades notes).include?(params[:tagname].split(':').first)
      params[:t] = params[:tagname]
      params[:tagname] = ""
    end
    render layout: false
  end

  def graph
    render layout: false
  end

  def graph_data
    render json: params.key?(:limit) ? Tag.graph_data(params[:limit].to_i) : Tag.graph_data
  end

  def stats
    @start = params[:start] ? Time.parse(params[:start].to_s) : Time.now - 1.year
    @end = params[:end] ? Time.parse(params[:end].to_s) : Time.now
    tagname = params[:id]

    @tag_name = params[:id]
    @tags = Tag.where(name: params[:id])

    return if @tags.empty?

    @tag_notes = @tags.first.contribution_graph_making('note', @start, @end)
    @tag_wikis = @tags.first.contribution_graph_making('page', @start, @end)
    @tag_questions = @tags.first.quiz_graph(@start, @end)
    @tag_comments = @tags.first.comment_graph(@start, @end)
    @subscriptions = @tags.first.subscription_graph(@start, @end)

    @all_subscriptions = TagSelection.graph(@start, @end)

    @answers = Node.published.questions
      .where(created: @start.to_i..@end.to_i)
      .where(nid: Node.find_by_tag(tagname)).joins(:comments).size
    @questions = Node.published.questions
      .where(created: @start.to_i..@end.to_i)
      .where(nid: Node.find_by_tag(tagname)).size
  end

  private

  def order_string
    if params[:search] || @toggle == "uses"
      params[:order] == "asc" ? "count ASC" : "count DESC"
    else
      params[:order] == "asc" ? "name ASC" : "name DESC"
    end
  end

  def fetch_counts
    # Enhancement #6306 - Add counts to `by type` dropdown on tag pages
    @counts = {}
    @counts[:posts] = Node.for_tagname_and_type(params[:id], 'note', wildcard: @wildcard).where('node.nid NOT IN (?)', @qids).size
    @counts[:questions] = Node.for_tagname_and_type(params[:id], 'note', question: true, wildcard: @wildcard).where('node.nid IN (?)', @qids).size
    @counts[:wiki] = Node.for_tagname_and_type(params[:id], 'page', wildcard: @wildcard).size
    params[:counts] = @counts
    # end Enhancement #6306 ============================================

    @total_posts = case @node_type
    when 'note'
      @notes.size
    when 'questions'
      @questions.size
    when 'wiki'
      @wikis.size
    when 'maps'
      @nodes.size
    end
  end
end
