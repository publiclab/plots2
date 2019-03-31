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

    { notes: notes,
      wikis: wikis,
      profiles: profiles,
      tags: tags,
      maps: maps,
      questions: questions }
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

    user_scope.limit(search_criteria.limit)
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
    Tag.where(name: sterms)
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
  def tagNearbyNodes(coordinates, tag, period = { "from" => nil, "to" => nil }, sort_by = nil, order_direction = nil, limit = 10)
    raise("Must contain all four coordinates") if coordinates["nwlat"].nil?
    raise("Must contain all four coordinates") if coordinates["nwlng"].nil?
    raise("Must contain all four coordinates") if coordinates["selat"].nil?
    raise("Must contain all four coordinates") if coordinates["selng"].nil?

    raise("Must be a float") unless coordinates["nwlat"].is_a? Float
    raise("Must be a float") unless coordinates["nwlng"].is_a? Float
    raise("Must be a float") unless coordinates["selat"].is_a? Float
    raise("Must be a float") unless coordinates["selng"].is_a? Float

    raise("If 'from' is not null, must contain date") if period["from"] && !(period["from"].is_a? Date)
    raise("If 'to' is not null, must contain date") if period["to"] && !(period["to"].is_a? Date)

    nodes_scope = Node.select(:nid)
                      .where('`latitude` >= ? AND `latitude` <= ?', coordinates["selat"], coordinates["nwlat"])
                      .where(status: 1)

    if tag.present?
      nodes_scope = NodeTag.joins(:tag)
        .where('name LIKE ?', tag)
        .where(nid: nodes_scope.select(:nid))
    end

    nids = nodes_scope.collect(&:nid).uniq || []

    # If the period["from"] was not specified, we use (1990,01,01)
    # If the period["to"] was not specified, we use 'now'
    period["from"] = period["from"].nil? ? Date.new(1990, 01, 01).to_time.to_i : period["from"].to_time.to_i
    period["to"] = period["to"].nil? ? Time.now.to_i : period["to"].to_time.to_i
    if period["from"] > period["to"]
      period["from"], period["to"] = period["to"], period["from"]
    end

    items = Node.includes(:tag)
      .references(:node, :term_data)
      .where('node.nid IN (?)', nids)
      .where('`longitude` >= ? AND `longitude` <= ?', coordinates["nwlng"], coordinates["selng"])
      .where('created BETWEEN ' + period["from"].to_s + ' AND ' + period["to"].to_s)

    # selects the items whose node_tags don't have the location:blurred tag
    items.select do |item|
      item.node_tags.none? do |node_tag|
        node_tag.name == "location:blurred"
      end
    end

    # sort nodes by recent activities if the sort_by==recent
    if sort_by == "recent"
      items.order("changed #{order_direction}")
           .limit(limit)
    else
      items.order(Arel.sql("created #{order_direction}"))
           .limit(limit)
            end
  end

  # Search nearby people with respect to given latitude, longitute and tags
  # and package up as a DocResult
  def tagNearbyPeople(coordinates, tag, field, period = nil, sort_by = nil, order_direction = nil, limit = 10)
    raise("Must contain all four coordinates") if coordinates["nwlat"].nil?
    raise("Must contain all four coordinates") if coordinates["nwlng"].nil?
    raise("Must contain all four coordinates") if coordinates["selat"].nil?
    raise("Must contain all four coordinates") if coordinates["selng"].nil?

    raise("Must be a float") unless coordinates["nwlat"].is_a? Float
    raise("Must be a float") unless coordinates["nwlng"].is_a? Float
    raise("Must be a float") unless coordinates["selat"].is_a? Float
    raise("Must be a float") unless coordinates["selng"].is_a? Float

    raise("If 'from' is not null, must contain date") if period["from"] && !(period["from"].is_a? Date)
    raise("If 'to' is not null, must contain date") if period["to"] && !(period["to"].is_a? Date)

    user_locations = User.where('rusers.status <> 0')
                         .joins(:user_tags)
                         .where('value LIKE ?', 'lat%')
                         .where('REPLACE(value, "lat:", "") BETWEEN ' + coordinates["selat"].to_s + ' AND ' + coordinates["nwlat"].to_s)
                         .distinct

    if tag.present?
      if field.present? && field == 'node_tag'
        tids = Tag.where("term_data.name = ?", tag).collect(&:tid).uniq || []
        uids = TagSelection.where('tag_selections.tid IN (?)', tids).collect(&:user_id).uniq || []
      else
        uids = User.joins(:user_tags)
                   .where('user_tags.value = ?', tag)
                   .where(id: user_locations.select("rusers.id"))
                   .collect(&:id).uniq || []
      end
      user_locations = user_locations.where('rusers.id IN (?)', uids).distinct
    end

    uids = user_locations.collect(&:id).uniq || []

    items = User.where('rusers.status <> 0')
      .joins(:user_tags)
      .where('rusers.id IN (?)', uids)
      .where('user_tags.value LIKE ?', 'lon%')
      .where('REPLACE(user_tags.value, "lon:", "") BETWEEN ' + coordinates["nwlng"].to_s + ' AND ' + coordinates["selng"].to_s)

    # selects the items whose node_tags don't have the location:blurred tag
    items.select do |item|
      item.user_tags.none? do |user_tag|
        user_tag.name == "location:blurred"
      end
    end

    # Here we use period["from"] and period["to"] in the query only if they have been specified,
    # so we avoid to join revision table
    if !period["from"].nil? || !period["to"].nil?
      items = items.joins(:revisions).where("node_revisions.status = 1")\
                   .distinct
      items = items.where('node_revisions.timestamp > ' + period["from"].to_time.to_i.to_s) unless period["from"].nil?
      items = items.where('node_revisions.timestamp < ' + period["to"].to_time.to_i.to_s) unless period["to"].nil?
    end

    # sort users by their recent activities if the sort_by==recent

    if sort_by == "recent"
      items.joins(:revisions).where("node_revisions.status = 1")\
           .order("node_revisions.timestamp #{order_direction}")
           .distinct
    elsif sort_by == "content"
      ids = items.collect(&:id).uniq || []
      User.select('`rusers`.*, count(`node`.uid) AS ord')
          .joins(:node)
          .where('rusers.id IN (?)', ids)
          .group('`node`.`uid`')
          .order("ord #{order_direction}")
    else
      items.order("created_at #{order_direction}")
            .limit(limit)
    end
  end

  def find_users(query, limit, type = nil)
    users = if type == 'tag'
              User.where('rusers.status = 1')
                  .joins(:user_tags)\
                  .where('user_tags.value LIKE ?', '%' + query + '%')\
            elsif ActiveRecord::Base.connection.adapter_name == 'Mysql2'
              type == 'username' ? User.search_by_username(query).where('rusers.status = ?', 1) : User.search(query).where('rusers.status = ?', 1)
            else
              User.where('username LIKE ? AND rusers.status = 1', '%' + query + '%')
            end

    users.limit(limit)
  end
end
