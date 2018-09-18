class SearchService
  def initialize; end

  # Run a search in any of the associated systems for references that contain the search string
  # and package up as a DocResult
  def textSearch_all(search_criteria)
    sresult = DocList.new

    # notes
    noteList = textSearch_notes(search_criteria.query, search_criteria.limit)
    sresult.addAll(noteList.items)

    # Node search
    nodeList = textSearch_pages(search_criteria.query, search_criteria.limit)
    sresult.addAll(nodeList.items)

    # User profiles
    search_criteria.add_sort_by("recent")
    userList = profiles(search_criteria)
    sresult.addAll(userList.items)

    # Tags
    tagList = textSearch_tags(search_criteria.query, search_criteria.limit)
    sresult.addAll(tagList.items)

    # maps
    mapList = textSearch_maps(search_criteria.query, search_criteria.limit)
    sresult.addAll(mapList.items)

    # questions
    qList = textSearch_questions(search_criteria.query, search_criteria.limit)
    sresult.addAll(qList.items)

    sresult
  end

  # Search profiles for matching text with optional order_by=recent param and
  # sorted direction DESC by default
  # then the list is packaged up as a DocResult

  # If no sort_by value present, then it returns a list of profiles ordered by id DESC
  # a recent activity may be a node creation or a node revision
  def profiles(search_criteria)
    limit = search_criteria.limit ? search_criteria.limit : 10

    user_scope = find_users(search_criteria.query, limit, search_criteria.field)

    user_scope =
      if search_criteria.sort_by == "recent"
        user_scope.joins(:revisions)
                  .order("node_revisions.timestamp #{search_criteria.order_direction}")
                  .distinct
      else
        user_scope.order(id: :desc)
      end

    users = user_scope.limit(limit)

    sresult = DocList.new
    users.each do |match|
      doc = DocResult.fromSearch(0, 'user', '/profile/' + match.name, match.username, 'USERS', 0)
      sresult.addDoc(doc)
    end

    sresult
  end

  # Search notes for matching strings and package up as a DocResult
  def textSearch_notes(srchString, limit = 25)
    sresult = DocList.new

    nodes = find_notes(srchString, limit)
    nodes.each do |match|
      doc = DocResult.fromSearch(match.nid, 'file', match.path, match.title, 'NOTES', 0)
      sresult.addDoc(doc)
    end

    sresult
  end

  # Search nodes package up as a DocResult
  def textSearch_pages(srchString, limit = 25)
    sresult = DocList.new

    nodes = find_pages(srchString, limit)

    nodes.each do |match|
      doc = DocResult.fromSearch(match.nid, 'file', match.path, match.title, 'PAGES', 0)
      sresult.addDoc(doc)
    end

    sresult
  end

  # Search maps for matching text and package up as a DocResult
  def textSearch_maps(srchString, limit = 25)
    sresult = DocList.new

    maps = find_maps(srchString, limit)

    maps.each do |match|
      doc = DocResult.fromSearch(match.nid, 'map', match.path, match.title, 'PLACES', 0)
      sresult.addDoc(doc)
    end

    sresult
  end

  # Search documents with matching tag values and package up as a DocResult
  # The search string that is passed in is split into tokens, and the tag names are compared and
  # chained to the notes that are tagged with those values
  def textSearch_tags(srchString, limit = 10)
    sresult = DocList.new

    # Tags
    sterms = srchString.split(' ')
    tlist = Tag.where(name: sterms)
      .joins(:node_tag)
      .joins(:node)
      .where('node.status = 1')
      .select('DISTINCT node.nid,node.title,node.path')
      .limit(limit)
    tlist.each do |match|
      tagdoc = DocResult.fromSearch(match.nid, 'tag', match.path, match.title, 'TAGS', 0)
      sresult.addDoc(tagdoc)
    end

    sresult
  end

  # Search question entries for matching text and package up as a DocResult
  def textSearch_questions(srchString, limit = 25)
    sresult = DocList.new

    questions = find_questions(srchString, limit)

    questions.each do |match|
      doc = DocResult.fromSearch(match.nid, 'question-circle', match.path(:question), match.title, 'QUESTIONS', match.answers.length.to_i)
      sresult.addDoc(doc)
    end

    sresult
  end

  # Search nearby nodes with respect to given latitude, longitute and tags
  # and package up as a DocResult
  def tagNearbyNodes(srchString, tagName, limit = 10)
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
      .limit(limit)
      .order('node.nid DESC')

    items.each do |match|
      blurred = false

      match.node_tags.each do |tag|
        if tag.name == "location:blurred"
          blurred = true
          break
        end
      end

      doc = DocResult.fromLocationSearch(match.nid, 'coordinates', match.path(:items), match.title, 'PLACES', match.answers.length.to_i, match.lat, match.lon, blurred)
      sresult.addDoc(doc)
    end
    sresult
  end

  # Returns the location of people with most recent contributions.
  # The method receives as parameter the number of results to be
  # returned and as optional parameter a user tag. If the user tag
  # is present, the method returns only the location of people
  # with that specific user tag.
  def people_locations(srchString, tagName = nil)
    sresult = DocList.new

    user_scope = find_locations(srchString, tagName)

    user_scope.each do |user|
      blurred = user.has_power_tag("location") ? user.get_value_of_power_tag("location") : false
      doc = DocResult.fromLocationSearch(user.id, 'people_coordinates', user.path, user.username, 'PLACES', 0, user.lat, user.lon, blurred)
      sresult.addDoc(doc)
    end

    sresult
  end

  def find_users(query, limit, type = nil)
    users =
      if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
        type == "username" ? User.search_by_username(query).where('rusers.status = ?', 1) : User.search(query).where('rusers.status = ?', 1)
      else
        User.where('username LIKE ? AND rusers.status = 1', '%' + query + '%')
      end
    users = users.limit(limit)
  end

  def find_notes(input, limit = 25, order = :natural, type = :boolean)
    Node.search(query: input, order: order, type: type, limit: limit)
        .where("`node`.`type` = 'note'")
  end

  def find_pages(input, limit = 25, order = :natural, type = :boolean)
    Node.search(query: input, order: order, type: type, limit: limit)
        .where("`node`.`type` = 'page' OR `node`.`type` = 'place' OR `node`.`type` = 'tool'")
  end

  def find_maps(input, limit = 25, order = :natural, type = :boolean)
    Node.search(query: input, order: order, type: type, limit: limit)
        .where("`node`.`type` = 'map'")
  end

  def find_questions(input, limit = 25, order = :natural, type = :boolean)
    Node.search(query: input, order: order, type: type, limit: limit)
        .where("`node`.`type` = 'note'")
        .joins(:tag)
        .where('term_data.name LIKE ?', 'question:%')
        .distinct
  end

  def find_locations(limit, user_tag = nil)
    user_locations = User.where('rusers.status <> 0')\
                         .joins(:user_tags)\
                         .where('value LIKE "lat:%"')\
                         .includes(:revisions)\
                         .order("node_revisions.timestamp DESC")\
                         .distinct
    if user_tag.present?
      user_locations = User.joins(:user_tags)\
                       .where('user_tags.value LIKE ?', user_tag)\
                       .where(id: user_locations.select("rusers.id"))
    end

    user_locations = user_locations.limit(limit)

    user_locations
  end
end
