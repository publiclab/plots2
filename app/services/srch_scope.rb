# This class provides common methods that Typehead and Search services use
class SrchScope
  def self.find_users(input, limit)
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      User.search(input)
          .order('id DESC') # do we need this line?
          .where('rusers.status = ?', 1)
          .limit(limit)
    else
      User.order('id DESC')
          .where('username LIKE ? AND rusers.status = 1', '%' + input + '%')
          .limit(limit)
    end
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
end
