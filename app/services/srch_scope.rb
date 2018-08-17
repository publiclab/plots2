# This class provides common methods that Typehead and Search services use
class SrchScope
  def self.find_users(query, type = nil, limit)
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      users = type == "username" ? User.search_by_username(query).where('rusers.status = ?', 1) : User.search(query).where('rusers.status = ?', 1)
    else
      users = User.where('username LIKE ? AND rusers.status = 1', '%' + query + '%')
    end
    users = users.limit(limit)
  end

  def self.find_tags(input, limit)
    tags = Tag.includes(:node)
      .references(:node)
      .where('node.status = 1')
      .limit(limit)
      .where('name LIKE ?', '%' + input + '%')

    tags.limit(limit)
  end

  def self.find_nodes(input, limit, order)
    nodes = Node.search(query: input, order: order, limit: limit)
                .group(:nid)
                .where('node.status': 1)
  end

  def self.find_notes(input, limit)
    notes = Node.order('nid DESC')
                .where('type = "note" AND node.status = 1 AND title LIKE ?', '%' + input + '%')

    notes.limit(limit)
  end

  def self.find_comments(input, limit)
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      Comment.search(input)
             .order('nid DESC')
             .where(status: 1)
             .limit(limit)
    else
      Comment.order('nid DESC')
             .where('status = 1 AND comment LIKE ?', '%' + input + '%')
             .limit(limit)
    end
  end

  def self.find_maps(input, limit)
    maps = Node.where('type = "map" AND node.status = 1 AND title LIKE ?', '%' + input + '%')
               .limit(limit)
  end

  def self.find_wikis(input, limit, order)
    wikis = find_nodes(input, limit, order).where("node.type": "page")
  end

  def self.find_questions(input, limit, order)
    questions = find_nodes(input, limit, order)
      .where('node.type': 'note')
      .joins(:tag)
      .where('term_data.name LIKE ?', 'question:%')
  end

  def self.find_locations(limit, user_tag = nil)
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

    user_locations = user_locations.limit(limit.to_i)

    user_locations
  end
end
