# The SearchService class is a utility class whose purpose is to provide detailed responses to queries within
# different categories (record types, functionality, subsystems, etc).
# Though similar in operation to the TypeaheadService, the implementation is separate, in that the goal of the response
# is to provide _detailed_ results at a deep level.  In effect, TypeaheadService provides pointers to
# better searches, while SearchService provides deep and detailed information.
# TODO: Refactor TypeaheadService and SearchService so that common functions come from a higher level class?

class SearchService
  def initialize; end

  def users(params)
    @users ||= find_users(params)
  end

  def tags(params)
    @tags ||= find_tags(params)
  end

  def nodes(params)
    @nodes ||= find_nodes(params)
  end

  def notes(params)
    @notes ||= find_notes(params)
  end

  def maps(params)
    @maps ||= find_maps(params)
  end

  def comments
    @comments ||= find_comments(params)
  end

  def find_users(input, limit = 10)
    User.limit(limit)
      .order('id DESC')
      .where(status: 1)
      .where('username LIKE ?', '%' + input + '%')
  end

  def find_tags(input, limit = 5)
    Tag.includes(:node)
      .references(:node)
      .where('node.status = 1')
      .limit(limit)
      .where('name LIKE ?', '%' + input + '%')
  end

  def find_comments(input, limit = 5)
    Comment.limit(limit)
      .order('nid DESC')
      .where('status = 1 AND comment LIKE ?', '%' + input + '%')
  end

  def find_nodes(input, limit = 5)
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      nids = Node.search(input)
        .group(:nid)
        .includes(:node)
        .references(:node)
        .limit(limit)
        .where("node.type": %w(note page), "node.status": 1)
        .order('node.changed DESC')
        .collect(&:nid)
      Node.find nids
    else
      Node.limit(limit)
        .group(:nid)
        .where(type: %w(note page), status: 1)
        .order(changed: :desc)
        .where('title LIKE ?', '%' + input + '%')
    end
  end

  def find_notes(input, limit = 5)
    Node.limit(limit)
      .order('nid DESC')
      .where('type = "note" AND node.status = 1 AND title LIKE ?', '%' + input + '%')
  end

  def find_maps(input, limit = 5)
    Node.limit(limit)
      .order('nid DESC')
      .where('type = "map" AND node.status = 1 AND title LIKE ?', '%' + input + '%')
  end

  # Run a search in any of the associated systems for references that contain the search string
  def textSearch_all(srchString)
    sresult = DocList.new

    # notes
    noteList = textSearch_notes(srchString)
    sresult.addAll(noteList.items)

    # Node search
    Node.limit(5)
      .order('nid DESC')
      .where('(type = "page" OR type = "place" OR type = "tool") AND node.status = 1 AND title LIKE ?', '%' + srchString + '%')
      .select('title,type,nid,path').each do |match|
      doc = DocResult.fromSearch(match.nid, match.icon, match.path, match.title, '', 0)
      sresult.addDoc(doc)
    end
    # User profiles
    userList = textSearch_profiles(srchString)
    sresult.addAll(userList.items)

    # Tags
    tagList = textSearch_tags(srchString)
    sresult.addAll(tagList.items)
    # maps
    mapList = textSearch_maps(srchString)
    sresult.addAll(mapList.items)
    # questions
    qList = textSearch_questions(srchString)
    sresult.addAll(qList.items)

    sresult
  end

  # Search profiles for matching text
  def textSearch_profiles(srchString)
    sresult = DocList.new

    # User profiles
    users(srchString).each do |match|
      doc = DocResult.fromSearch(0, 'user', '/profile/' + match.name, match.name, '', 0)
      sresult.addDoc(doc)
    end

    sresult
  end

  # Search notes for matching strings
  def textSearch_notes(srchString)
    sresult = DocList.new

    # notes
    find_notes(srchString, 25).each do |match|
      doc = DocResult.fromSearch(match.nid, 'file', match.path, match.title, match.body.split(/#+.+\n+/, 5)[1], 0)
      sresult.addDoc(doc)
    end

    sresult
  end

  # Search maps for matching text
  def textSearch_maps(srchString)
    sresult = DocList.new

    # maps
    maps(srchString).select('title,type,nid,path').each do |match|
      doc = DocResult.fromSearch(match.nid, match.icon, match.path, match.title, '', 0)
      sresult.addDoc(doc)
    end

    sresult
  end

  # Search documents with matching tag values
  # The search string that is passed in is split into tokens, and the tag names are compared and
  # chained to the notes that are tagged with those values
  def textSearch_tags(srchString)
    sresult = DocList.new

    # Tags
    sterms = srchString.split(' ')
    tlist = Tag.where(name: sterms)
      .joins(:node_tag)
      .joins(:node)
      .where('node.status = 1')
      .select('DISTINCT node.nid,node.title,node.path')
    tlist.each do |match|
      tagdoc = DocResult.fromSearch(match.nid, 'tag', match.path, match.title, '', 0)
      sresult.addDoc(tagdoc)
    end

    sresult
  end

  # Search question entries for matching text
  def textSearch_questions(srchString)
    sresult = DocList.new

    questions = Node.where(
      'type = "note" AND node.status = 1 AND title LIKE ?',
      '%' + srchString + '%'
    )
      .joins(:tag)
      .where('term_data.name LIKE ?', 'question:%')
      .order('node.nid DESC')
      .limit(25)
    questions.each do |match|
      doc = DocResult.fromSearch(match.nid, 'question-circle', match.path(:question), match.title, 0, match.answers.length.to_i)
      sresult.addDoc(doc)
    end

    sresult
  end

  # Search nearby nodes with respect to given latitude, longitute and tags
  def tagNearbyNodes(srchString, tagName)
    sresult = DocList.new

    lat, lon =  srchString.split(',')

    nodes_scope = NodeTag.joins(:tag)
      .where('name LIKE ?', 'lat:' + lat[0..lat.length - 2] + '%')

    if tagName.present?
      nodes_scope = NodeTag.joins(:tag)
                           .where('name LIKE ?', tagName)
                           .where(nid: nodes_scope.select(:nid))
    end

    nids = nodes_scope.collect(&:nid).uniq || []

    items = Node.includes(:tag)
      .references(:node, :term_data)
      .where('node.nid IN (?) AND term_data.name LIKE ?', nids, 'lon:' + lon[0..lon.length - 2] + '%')
      .limit(200)
      .order('node.nid DESC')

    items.each do |match|
      blurred = false

      match.node_tags.each do |tag|
        if tag.name == "location:blurred"
          blurred = true
          break
        end
      end

      doc = DocResult.fromLocationSearch(match.nid, 'coordinates', match.path(:items), match.title, 0, match.answers.length.to_i, match.lat, match.lon, blurred)
      sresult.addDoc(doc)
    end
    sresult
  end

  # GET X number of latest people/contributors
  # X = srchString
  def recentPeople(srchString, tagName = nil)
    sresult = DocList.new

    nodes = Node.all.order("changed DESC").limit(srchString).distinct
    users = []
    nodes.each do |node|
      if node.author.status != 0
        if tagName.blank?
          users << node.author.user
        else
          users << node.author.user if node.author.user.has_tag(tagName)
        end
      end
    end
    users = users.uniq
    users.each do |user|
      next unless user.has_power_tag("lat") && user.has_power_tag("lon")
      blurred = false
      if user.has_power_tag("location")
        blurred = user.get_value_of_power_tag("location")
      end
      doc = DocResult.fromLocationSearch(user.id, 'people_coordinates', user.path, user.username, 0, 0, user.lat, user.lon, blurred)
      sresult.addDoc(doc)
    end

    sresult
  end
end
