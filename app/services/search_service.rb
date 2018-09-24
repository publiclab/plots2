class SearchService
  def initialize; end

  # Run a search in any of the associated systems for references that contain the search string
  def search_all(search_criteria)
    notes = search_notes(search_criteria.query)

    wikis = search_wikis(search_criteria.query, search_criteria.limit)

    search_criteria.sort_by = "recent"
    profiles = search_profiles(search_criteria)

    tags = search_tags(search_criteria.query, search_criteria.limit)

    maps = search_maps(search_criteria.query, search_criteria.limit)

    questions = search_questions(search_criteria.query, search_criteria.limit)

    all_results = { :notes => notes,
                    :wikis => wikis,
                    :profiles => profiles,
                    :tags => tags,
                    :maps => maps,
                    :questions => questions }
  end

  # Search profiles for matching text with optional order_by=recent param and
  # sorted direction DESC by default
  # then the list is packaged up as a DocResult

  # If no sort_by value present, then it returns a list of profiles ordered by id DESC
  # a recent activity may be a node creation or a node revision
  def search_profiles(search_criteria)
    user_scope = find_users(search_criteria.query, search_criteria.limit, search_criteria.field)

    user_scope =
      if search_criteria.sort_by == "recent"
        user_scope.joins(:revisions)
        .order("node_revisions.timestamp #{search_criteria.order_direction}")
        .distinct
      else
        user_scope.order(id: :desc)
      end

    users = user_scope.limit(search_criteria.limit)
  end

  def search_notes(input, limit = 25, order = :natural, type = :boolean)
    Node.search(query: input, order: order, type: type, limit: limit)
        .where("`node`.`type` = 'note'")
  end

  def search_wikis(input, limit = 25, order = :natural, type = :boolean)
    Node.search(query: input, order: order, type: type, limit: limit)
        .where("`node`.`type` = 'page' OR `node`.`type` = 'place' OR `node`.`type` = 'tool'")
  end

  def search_maps(input, limit = 25, order = :natural, type = :boolean)
    Node.search(query: input, order: order, type: type, limit: limit)
        .where("`node`.`type` = 'map'")
  end

  # The search string that is passed in is split into tokens, and the tag names are compared and
  # chained to the notes that are tagged with those values
  def search_tags(srchString, limit = 10)
    sterms = srchString.split(' ')
    tlist = Tag.where(name: sterms)
      .joins(:node_tag)
      .joins(:node)
      .where('node.status = 1')
      .select('DISTINCT node.nid,node.title,node.path')
      .limit(limit)
  end

  # Search question entries for matching text and package up as a DocResult
  def search_questions(input, limit = 25, order = :natural, type = :boolean)
    Node.search(query: input, order: order, type: type, limit: limit)
        .where("`node`.`type` = 'note'")
        .joins(:tag)
        .where('term_data.name LIKE ?', 'question:%')
        .distinct
  end

  # Search nearby nodes with respect to given latitude, longitute and tags
  # and package up as a DocResult
  def tagNearbyNodes(srchString, tagName, limit = 10)
    raise("Must separate coordinates with ,") unless srchString.include? ","

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

    # selects the items whose node_tags don't have the location:blurred tag
    items.select do |item|
      item.node_tags.none? do |node_tag|
        node_tag.name == "location:blurred"
      end
    end
  end

  # Returns the location of people with most recent contributions.
  # The method receives as parameter the number of results to be
  # returned and as optional parameter a user tag. If the user tag
  # is present, the method returns only the location of people
  # with that specific user tag.
  def people_locations(srchString, user_tag = nil)
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

    user_locations.limit(srchString)
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
end
