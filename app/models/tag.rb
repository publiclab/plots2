class Tag < ApplicationRecord
  extend RawStats
  self.table_name = 'term_data'
  self.primary_key = 'tid'

  has_many :tag_selection, foreign_key: 'tid'
  has_many :node_tag, foreign_key: 'tid'

  # we're not really using the filter_by_type stuff here:
  has_many :node, through: :node_tag do
    def filter_by_type(type, limit = 10)
      where(status: 1, type: type)
        .limit(limit)
        .order('created DESC')
    end
  end

  validates :name, presence: true
  validates :name, format: { with: /\A[\w\.:-]*[\w\.!-]*\z/, message: 'can only include letters, numbers, and dashes' }
  # validates :name, :uniqueness => { case_sensitive: false  }

  def id
    tid
  end

  # alias
  def nid
    id
  end

  def title
    name
  end

  def path
    "/tag/#{name}"
  end

  def run_count
    self.count = NodeTag.where(tid: tid).count
    save
  end

  def subscriptions
    tag_selection.where(following: true)
  end

  # nodes this tag has been used on; no wildcards
  def nodes
    Node.where(nid: node_tag.collect(&:nid))
  end

  def self.nodes_frequency(starting, ending)
    ids = Node.where(created: starting.to_i..ending.to_i).map(&:node_tags).flatten.map(&:tid)
    hash = ids.uniq.map { |id| p (Tag.find id).name, ids.count(id) }.to_h
    hash.sort_by { |_, v| v }.reverse.first(10).to_h
  end

  def belongs_to(current_user, node_id)
    node_tag = node_tag.find_by(nid: node_id)
    node_tag && node_tag.uid == current_user.uid || node_tag.node.uid == current_user.uid
  end

  def self.contributors(tagname)
    tag = Tag.includes(:node).where(name: tagname).first
    return [] if tag.nil?

    nodes = tag.node.includes(:revision, :comments, :answers).where(status: 1)
    uids = nodes.collect(&:uid)
    nodes.each do |n|
      uids += n.comments.collect(&:uid)
      uids += n.answers.collect(&:uid)
      uids += n.revision.collect(&:uid)
    end
    uids = uids.uniq
    User.where(id: uids)
  end

  def self.contributor_count(tagname)
    uids = Tag.contributors(tagname)
    uids.length
  end

  # finds highest viewcount nodes
  def self.find_top_nodes_by_type(tagname:, type: 'wiki', limit: 10)
    Node.where(type: type)
        .where('term_data.name = ?', tagname)
        .order('node.views DESC')
        .limit(limit)
        .includes(:node_tag, :tag)
  .references(:term_data)
  end

  # finds recent nodes - should drop "limit" and allow use of chainable .limit()
  def self.find_nodes_by_type(tagnames, type = 'note', limit = 10)
    nodes = Node.where(status: 1, type: type)
                .includes(:tag)
                .references(:term_data)
                .where('term_data.name IN (?)', tagnames)
    # .select(%i[node.nid node.status node.type community_tags.nid community_tags.tid term_data.name term_data.tid])
    # above select could be added later for further optimization
    # .where('term_data.name IN (?) OR term_data.parent in (?)', tagnames, tagnames) # greedily fetch children
    tags = Tag.where('term_data.name IN (?)', tagnames)
    parents = Node.where(status: 1, type: type)
                  .includes(:tag)
                  .references(:term_data)
                  .where('term_data.name IN (?)', tags.collect(&:parent))
    order = 'node_revisions.timestamp DESC'
    order = 'created DESC' if type == 'note'
    Node.where('node.nid IN (?)', (nodes + parents).collect(&:nid))
        .includes(:revision, :tag)
        .references(:node_revisions)
        .where(status: 1)
        .limit(limit)
        .order(order)
  end

  def self.counter(tagname)
    Node.where(type: %w(note page))
        .where('term_data.name = ?', tagname)
        .includes(:node_tag, :tag)
        .references(:term_data)
        .count
  end

  # just like find_nodes_by_type, but searches wiki pages, places, and tools
  def self.find_pages(tagnames, limit = 10)
    find_nodes_by_type(tagnames, %w(page place tool), limit)
  end

  def self.find_nodes_by_type_with_all_tags(tagnames, type = 'note', limit = 10)
    nids = []
    tagnames.each do |tagname|
      # tids = Tag.where('term_data.name IN (?) OR term_data.parent IN (?)', tagnames, tagnames) # greedily fetch children
      tids = Tag.where('term_data.name IN (?)', tagnames)
                .collect(&:tid)
      tag_nids = NodeTag.where('tid IN (?)', tids)
                                       .collect(&:nid)
      tag = Tag.where(name: tagname).last
      next unless tag

      parents = Node.where(status: 1, type: type)
                    .includes(:revision, :tag)
                    .references(:term_data)
                    .where('term_data.name LIKE ?', tag.parent)
      nids += tag_nids + parents.collect(&:nid)
    end
    Node.where('nid IN (?)', nids)
        .order('nid DESC')
        .where(status: 1)
        .limit(limit)
  end

  def self.find_popular_notes(tagname, views = 20, limit = 10)
    Node.where(type: 'note')
        .where('term_data.name = ? AND node.views > (?)', tagname, views)
        .order('node.nid DESC')
        .limit(limit)
        .includes(:node_tag, :tag)
        .references(:community_tags)
  end

  def self.exists?(tagname, nid)
    !NodeTag.where('nid = ? AND term_data.name = ?', nid, tagname)
                           .joins(:tag).empty?
  end

  def self.is_powertag?(tagname)
    !tagname.match(':').nil?
  end

  def self.follower_count(tagname)
    uids = TagSelection.joins(:tag)
                       .where('term_data.name = ? AND following = ?', tagname, true)
                       .collect(&:user_id)
    User.where(id: uids)
        .where(status: [1, 4])
        .count
  end

  def self.followers(tagname)
    uids = TagSelection.joins(:tag)
                       .where('term_data.name = ? AND following = ?', tagname, true)
                       .collect(&:user_id)
    User.where(id: uids)
        .where(status: [1, 4])
  end

  def self.sort_according_to_followers(raw_tags, order)
    tags_with_their_followers = []

    raw_tags.each do |i|
      tags_with_their_followers << { "number_of_followers" => Tag.follower_count(i.name), "tags" => i }
    end

    tags_with_their_followers.sort_by! { |key| key["number_of_followers"] }

    if order != "asc"
      tags_with_their_followers.reverse!
    end

    tags_with_their_followers.map { |x| x["tags"] }
  end

  # OPTIMIZE: this too!
  def weekly_tallies(type = 'note', span = 52)
    weeks = {}
    tids = Tag.where('name IN (?)', [name])
              .collect(&:tid)
    nids = NodeTag.where('tid IN (?)', tids)
                                 .collect(&:nid)
    (1..span).each do |week|
      weeks[span - week] = Tag.nodes_for_period(
        type,
        nids,
        (Time.now.to_i - week.weeks.to_i).to_s,
        (Time.now.to_i - (week - 1).weeks.to_i).to_s
      ).count(:all)
    end
    weeks
  end

  def contribution_graph_making(type = 'note', start = Time.now - 1.year, fin = Time.now)
    weeks = {}
    week = span(start, fin)

    while week >= 1
      # initialising month variable with the month of the starting day
      #       # of the week
      month = (fin - (week * 7 - 1).days)

      # Now fetching the weekly data of notes or wikis

      current_week =
        Tag.nodes_for_period(
          type,
          nids,
          (fin.to_i - week.weeks.to_i).to_s,
          (fin.to_i - (week - 1).weeks.to_i).to_s
        ).count(:all)

      weeks[(month.to_f * 1000)] = current_week
      week -= 1
    end
    weeks
  end

  def quiz_graph(start = Time.now - 1.year, fin = Time.now)
    weeks = {}
    week = span(start, fin)
    questions = Node.published.questions.where(nid: nids)

    while week >= 1
      month = (fin - (week * 7 - 1).days)
      weekly_quiz = questions.where(created: range(fin, week))
        .count(:all)

      weeks[(month.to_f * 1000)] = weekly_quiz.count
      week -= 1
    end
    weeks
  end

  def comment_graph(start = Time.now - 1.year, fin = Time.now)
    weeks = {}
    week = span(start, fin)
    comments = Comment.where(nid: nids)

    while week >= 1
      month = (fin - (week * 7 - 1).days)
      weekly_comments = comments.where(timestamp: range(fin, week))
        .count(:all)

      weeks[(month.to_f * 1000)] = weekly_comments
      week -= 1
    end
    weeks
  end

  def self.nodes_for_period(type, nids, start, finish)
    Node.select(%i(created status type nid))
        .where(
          'type = ? AND status = 1 AND nid IN (?) AND created > ? AND created <= ?',
          type,
          nids.uniq,
          start,
          finish
        )
  end

  # Given a set of tags, return all users following
  # those tags. Return a dictionary of tags indexed by user.
  # Accepts array of Tags, outputs array of users as:
  # {user: <user>, tags: [<tags>]}
  # Used in subscription_mailer
  def self.subscribers(tags)
    tids = tags.collect(&:tid)
    # include special tid for indiscriminant subscribers who want it all!
    all_tag = Tag.find_by(name: 'everything')
    tids += [all_tag.tid] if all_tag
    usertags = TagSelection.where('tid IN (?) AND following = ?', tids, true)

    usertags_hash = {}

    usertags.each do |usertag|
      # For each row of (user,tag), build a user's tag subscriptions
      if (usertag.tid == all_tag) && usertag.tag.blank?
        Rails.logger.warn('WARNING: all_tag tid ' + all_tag.to_s + ' not found for Tag! Please correct this!')
        next
      end
      usertags_hash[usertag.user.name] = { user: usertag.user }
      usertags_hash[usertag.user.name][:tags] = Set.new if usertags_hash[usertag.user.name][:tags].nil?
      usertags_hash[usertag.user.name][:tags].add(usertag.tag)
    end

    usertags_hash
  end

  def self.find_research_notes(tagnames, limit = 10)
    Node.research_notes.where(status: 1)
        .includes(:revision, :tag)
        .references(:node_revisions)
        .where('term_data.name IN (?)', tagnames)
        .order('node_revisions.timestamp DESC')
        .limit(limit)
  end

  def followers_who_dont_follow_tags(tags)
    tag_followers = User.where(id: subscriptions.collect(&:user_id))
    uids = tags.collect(&:subscriptions).flatten.collect(&:user_id)
    following_given_tags = User.where(id: uids)
    tag_followers.reject { |user| following_given_tags.include? user }
  end

  # https://github.com/publiclab/plots2/pull/4266
  def self.trending(limit = 5, start_date = DateTime.now - 1.month, end_date = DateTime.now)
    Tag.select('term_data.name, plots.term_data.count') # ONLY_FULL_GROUP_BY, issue #8152 & #3120
       .joins(:node_tag, :node)
       .where('node.status = ?', 1)
       .where('node.created > ?', start_date.to_i)
       .where('node.created <= ?', end_date.to_i)
       .distinct
       .order('count DESC')
       .limit(limit)
  end

  # select nodes by tagname and user_id
  def self.tagged_nodes_by_author(tagname, user_id)
    if tagname[-1..-1] == '*'
      @wildcard = true
      Node.includes(:node_tag, :tag)
          .where('term_data.name LIKE(?) OR term_data.parent LIKE (?)', tagname[0..-2] + '%', tagname[0..-2] + '%')
          .references(:term_data, :node_tag)
          .where('node.uid = ?', user_id)
          .order('node.nid DESC')
    else
      Node.includes(:node_tag, :tag)
          .where('term_data.name = ? OR term_data.parent = ?', tagname, tagname)
          .references(:term_data, :node_tag)
          .where('node.uid = ?', user_id)
          .order('node.nid DESC')
    end
  end

  def self.tagged_node_count(tag_name)
    Node.where(status: 1, type: 'note')
        .includes(:revision, :tag)
        .references(:term_data, :node_revisions)
        .where('term_data.name = ?', tag_name)
        .count
  end

  def self.related(tag_name, count = 5)
    Rails.cache.fetch("related-tags/#{tag_name}/#{count}", expires_in: 1.weeks) do
      nids = NodeTag.joins(:tag)
                     .where(Tag.table_name => { name: tag_name })
                     .select(:nid)

      # sort them by how often they co-occur:
      nids = nids.group_by{ |v| v }.map{ |k, v| [k, v.size] }
      nids = nids.collect(&:first)[0..4]
                 .collect(&:nid) # take top 5

      Tag.joins(:node_tag)
         .where(NodeTag.table_name => { nid: nids })
         .where.not(name: tag_name)
         .group(:tid)
         .order(count: :desc)
         .limit(count)
    end
  end

  # for Cytoscape.js http://js.cytoscape.org/
  def self.graph_data(limit = 250)
    Rails.cache.fetch("graph-data/#{limit}", expires_in: 1.weeks) do
      data = {}
      data["tags"] = []
      Tag.joins(:node)
        .group(:tid)
        .where('node.status': 1)
        .order(count: :desc)
        .limit(limit).each do |tag|
        data["tags"] << {
          "name" => tag.name,
          "count" => tag.count
        }
      end
      data["edges"] = []
      data["tags"].each do |tag|
        Tag.related(tag["name"], 10).each do |related_tag|
          data["edges"] << { "from" => tag["name"], "to" => related_tag.name }
        end
      end
      data
    end
  end

  def self.all_tags_by_popularity
    Tag.all.order('count DESC').select { |tag| !(tag.name.include? ":") }.uniq(&:name).pluck(:name)
  end

  def subscription_graph(start = DateTime.now - 1.year, fin = DateTime.now)
    date_hash = {}
    week = start.to_date.step(fin.to_date, 7).count

    while week >= 1
      month = (fin - (week * 7 - 1).days)
      range = (fin - week.weeks)..(fin - (week - 1).weeks)
      weekly_subs = subscriptions.where(created_at: range)
                                 .size
      date_hash[month.to_f * 1000] = weekly_subs
      week -= 1
    end
    date_hash
  end

  private

  def tids
    Tag.where('name IN (?)', [name]).collect(&:tid)
  end

  def nids
    NodeTag.where('tid IN (?)', tids).collect(&:nid)
  end

  def span(start, fin)
    start.to_date.step(fin.to_date, 7).count
  end

  def range(fin, week)
    (fin.to_i - week.weeks.to_i).to_s..(fin.to_i - (week - 1).weeks.to_i).to_s
  end
end
