class SrchScope
  def self.find_users(query, type = nil, limit)
    users =
      if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
        type == "username" ? User.search_by_username(query).where('rusers.status = ?', 1) : User.search(query).where('rusers.status = ?', 1)
      else
        User.where('username LIKE ? AND rusers.status = 1', '%' + query + '%')
      end
    users = users.limit(limit)
  end

  # we can add a param for 'note' instead of having another method
  def self.find_nodes(input, _limit = 5, order = :default)
    Node.search(query: input, order: order, limit: 5)
        .group(:nid)
        .where('node.status': 1)
        .distinct
  end

  def self.find_notes(input, limit)
    Node.order('nid DESC')
        .where('type = "note" AND node.status = 1 AND title LIKE ?', '%' + input + '%')
        .distinct
        .limit(limit)
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
