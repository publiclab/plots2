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

  # If no sort_by value present, then it returns a list of profiles ordered by id DESC
  # a recent activity may be a node creation or a node revision
  def search_profiles(search_criteria)
    user_scope = find_users(search_criteria.query, search_criteria.limit, search_criteria.field)

    user_scope =
      if search_criteria.sort_by == "recent"
        user_scope.joins(:revisions)
        .where("node_revisions.status = 1")
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
  def search_tags(query, limit = 10)
    sterms = query.split(' ')
    tlist = Tag.where(name: sterms)
      .joins(:node_tag, :node)
      .where('node.status = 1')
      .select('DISTINCT node.nid,node.title,node.path')
      .limit(limit)
  end

  # Search question entries for matching text
  def search_questions(input, limit = 25, order = :natural, type = :boolean)
    Node.search(query: input, order: order, type: type, limit: limit)
        .where("`node`.`type` = 'note'")
        .joins(:tag)
        .where('term_data.name LIKE ?', 'question:%')
        .distinct
  end

  # Search nearby nodes with respect to given latitude, longitute and tags
  def tagNearbyNodes(coordinates, tag, limit = 10)
    raise("Must contain all four coordinates") if coordinates["nwlat"].nil?
    raise("Must contain all four coordinates") if coordinates["nwlng"].nil?
    raise("Must contain all four coordinates") if coordinates["selat"].nil?
    raise("Must contain all four coordinates") if coordinates["selng"].nil?

    raise("Must be a float") unless coordinates["nwlat"].is_a? Float
    raise("Must be a float") unless coordinates["nwlng"].is_a? Float
    raise("Must be a float") unless coordinates["selat"].is_a? Float
    raise("Must be a float") unless coordinates["selng"].is_a? Float

    nodes_scope = NodeTag.joins(:tag)
      .where('name LIKE ?', 'lat%')
      .where('REPLACE(name, "lat:", "") BETWEEN ' + coordinates["selat"].to_s + ' AND ' + coordinates["nwlat"].to_s)

    if tag.present?
      nodes_scope = NodeTag.joins(:tag)
        .where('name LIKE ?', tag)
        .where(nid: nodes_scope.select(:nid))
    end

    nids = nodes_scope.collect(&:nid).uniq || []

    items = Node.includes(:tag)
      .references(:node, :term_data)
      .where('node.nid IN (?)', nids)
      .where('term_data.name LIKE ?', 'lon%')
      .where('REPLACE(term_data.name, "lon:", "") BETWEEN ' + coordinates["nwlng"].to_s + ' AND ' + coordinates["selng"].to_s)
      .order('node.nid DESC')
      .limit(limit)

    # selects the items whose node_tags don't have the location:blurred tag
    items.select do |item|
      item.node_tags.none? do |node_tag|
        node_tag.name == "location:blurred"
      end
    end
  end

  # Search nearby people with respect to given latitude, longitute and tags
  # and package up as a DocResult
  def tagNearbyPeople(coordinates, tag, sort_by, limit = 10)
    raise("Must contain all four coordinates") if coordinates["nwlat"].nil?
    raise("Must contain all four coordinates") if coordinates["nwlng"].nil?
    raise("Must contain all four coordinates") if coordinates["selat"].nil?
    raise("Must contain all four coordinates") if coordinates["selng"].nil?

    raise("Must be a float") unless coordinates["nwlat"].is_a? Float
    raise("Must be a float") unless coordinates["nwlng"].is_a? Float
    raise("Must be a float") unless coordinates["selat"].is_a? Float
    raise("Must be a float") unless coordinates["selng"].is_a? Float

    user_locations = User.where('rusers.status <> 0')
                         .joins(:user_tags)
                         .where('value LIKE ?', 'lat%')
                         .where('REPLACE(value, "lat:", "") BETWEEN ' + coordinates["selat"].to_s + ' AND ' + coordinates["nwlat"].to_s)
                         .distinct

    if tag.present?
      user_locations = User.joins(:user_tags)
                           .where('user_tags.value LIKE ?', tag)
                           .where(id: user_locations.select("rusers.id"))
    end

    ids = user_locations.collect(&:id).uniq || []

    items = User.where('rusers.status <> 0')
      .joins(:user_tags)
      .where('rusers.id IN (?)', ids)
      .where('user_tags.value LIKE ?', 'lon%')
      .where('REPLACE(user_tags.value, "lon:", "") BETWEEN ' + coordinates["nwlng"].to_s + ' AND ' + coordinates["selng"].to_s)

    # selects the items whose node_tags don't have the location:blurred tag
    items.select do |item|
      item.user_tags.none? do |user_tag|
        user_tag.name == "location:blurred"
      end
    end

    # sort users by their recent activities if the sort_by==recent
    items = if sort_by == "recent"
              items.joins(:revisions).where("node_revisions.status = 1")\
                   .order("node_revisions.timestamp DESC")
                   .distinct
            else
              items.order(id: :desc)
                   .limit(limit)
            end
  end

  # Returns the location of people with most recent contributions.
  # The method receives as parameter the number of results to be
  # returned and as optional parameter a user tag. If the user tag
  # is present, the method returns only the location of people
  # with that specific user tag.
  def people_locations(query, user_tag = nil)
    user_locations = User.where('rusers.status <> 0')
                         .joins(:user_tags)
                         .where('value LIKE "lat:%"')
                         .includes(:revisions)
                         .order("node_revisions.timestamp DESC")
                         .distinct
    if user_tag.present?
      user_locations = User.joins(:user_tags)
                           .where('user_tags.value LIKE ?', user_tag)
                           .where(id: user_locations.select("rusers.id"))
    end
    user_locations.limit(query)
  end

 def find_users(query, limit, type = nil)
    users =
      if type == "tag"
        User.where('rusers.status = 1')
            .joins(:user_tags)\
            .where('user_tags.value LIKE ?', '%' + query + '%')\
      else if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
        type == "username" ? User.search_by_username(query).where('rusers.status = ?', 1) : User.search(query).where('rusers.status = ?', 1)
      else
        User.where('username LIKE ? AND rusers.status = 1', '%' + query + '%')
      end
    end

    users = users.limit(limit)
  end
end
