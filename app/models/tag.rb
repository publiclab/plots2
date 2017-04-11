class Tag < ActiveRecord::Base
  attr_accessible :vid, :name, :description, :weight
  self.table_name = 'term_data'
  self.primary_key = 'tid'

  has_many :tag_selection, foreign_key: 'tid'
  has_many :drupal_node_community_tag, foreign_key: 'tid'

  # we're not really using the filter_by_type stuff here:
  has_many :node, through: :drupal_node_tag do
    def filter_by_type(type, limit = 10)
      where(status: 1, type: type)
        .limit(limit)
        .order('created DESC')
    end
  end

  # the following probably never gets used; tag.node will use the above definition.
  # also, we're not really using the filter_by_type stuff here:
  has_many :node, through: :drupal_node_community_tag do
    def filter_by_type(type, limit = 10)
      where(status: 1, type: type)
        .limit(limit)
        .order('created DESC')
    end
  end

  validates :name, presence: :true
  validates :name, format: { with: /^[\w\.:-]*$/, message: 'can only include letters, numbers, and dashes' }
  # validates :name, :uniqueness => { case_sensitive: false }

  def id
    tid
  end

  def run_count
    self.count = DrupalNodeCommunityTag.where(tid: tid).count
    save
  end

  def subscriptions
    tag_selection
  end

  # nodes this tag has been used on; no wildcards
  def nodes
    nodes = Node.where(nid: drupal_node_community_tag.collect(&:nid))
  end

  def is_community_tag(nid)
    !drupal_node_community_tag.find_by_nid(nid).nil?
  end

  def belongs_to(current_user, nid)
    node_tag = drupal_node_community_tag.find_by_nid(nid)
    node_tag && node_tag.uid == current_user.uid || node_tag.node.uid == current_user.uid
  end

  # finds highest viewcount nodes
  def self.find_top_nodes_by_type(tagname, type = 'wiki', limit = 10)
    Node.where(type: type)
        .where('term_data.name = ?', tagname)
        .order('node.views DESC')
        .limit(limit)
        .include(:drupal_node_community_tag, :tag)
  end

  # finds recent nodes - should drop "limit" and allow use of chainable .limit()
  def self.find_nodes_by_type(tagnames, type = 'note', limit = 10)
    nodes = Node.where(status: 1, type: type)
                .includes(:drupal_node_revision, :tag)
                .where('term_data.name IN (?)', tagnames)
    # .where('term_data.name IN (?) OR term_data.parent in (?)', tagnames, tagnames) # greedily fetch children
    tags = Tag.where('term_data.name IN (?)', tagnames)
    parents = Node.where(status: 1, type: type)
                  .includes(:drupal_node_revision, :tag)
                  .where('term_data.name IN (?)', tags.collect(&:parent))
    Node.where('node.nid IN (?)', (nodes + parents).collect(&:nid))
        .includes(:drupal_node_revision, :tag)
        .where(status: 1)
        .order('node_revisions.timestamp DESC')
        .limit(limit)
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
      tag_nids = DrupalNodeCommunityTag.where('tid IN (?)', tids)
                                       .collect(&:nid)
      tag = Tag.where(name: tagname).last
      next unless tag
      parents = Node.where(status: 1, type: type)
                    .includes(:drupal_node_revision, :tag)
                    .where('term_data.name LIKE ?', tag.parent)
      nids += tag_nids + parents.collect(&:nid)
    end
    Node.where('nid IN (?)', nids)
        .order('nid DESC')
        .limit(limit)
  end

  def self.find_popular_notes(tagname, views = 20, limit = 10)
    Node.where(type: 'note')
        .where('term_data.name = ? AND node.views > (?)', tagname, views)
        .order('node.nid DESC')
        .limit(limit)
        .include(:drupal_node_community_tag, :tag)
  end

  def self.exists?(tagname, nid)
    !DrupalNodeCommunityTag.where('nid = ? AND term_data.name = ?', nid, tagname)
                           .joins(:tag).empty?
  end

  def self.is_powertag?(tagname)
    !tagname.match(':').nil?
  end

  def self.follower_count(tagname)
    TagSelection.joins(:tag)
                .where('term_data.name = ?', tagname)
                .count
  end

  def self.followers(tagname)
    uids = TagSelection.joins(:tag)
                       .where('term_data.name = ?', tagname)
                       .collect(&:user_id)
    DrupalUsers.where('uid in (?)', uids)
               .collect(&:user)
  end

  # OPTIMIZE: this too!
  def weekly_tallies(type = 'note', span = 52)
    weeks = {}
    tids = Tag.where('name IN (?)', [name])
              .collect(&:tid)
    nids = DrupalNodeCommunityTag.where('tid IN (?)', tids)
                                 .collect(&:nid)
    (1..span).each do |week|
      weeks[span - week] = Tag.nodes_for_period(
        type,
        nids,
        (Time.now.to_i - week.weeks.to_i).to_s,
        (Time.now.to_i - (week - 1).weeks.to_i).to_s
      ).count
    end
    weeks
  end

  def self.nodes_for_period(type, nids, start, finish)
    Node.select([:created, :status, :type, :nid])
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
    all_tag = Tag.find_by_name('everything')
    tids += [all_tag.tid] if all_tag
    usertags = TagSelection.where('tid IN (?) AND following = ?', tids, true)
    d = {}
    usertags.each do |usertag|
      # For each row of (user,tag), build a user's tag subscriptions
      if (usertag.tid == all_tag) && usertag.tag.nil?
        puts 'WARNING: all_tag tid ' + String(all_tag) + ' not found for Tag! Please correct this!'
        next
      end
      d[usertag.user.name] = { user: usertag.user }
      d[usertag.user.name][:tags] = Set.new if d[usertag.user.name][:tags].nil?
      d[usertag.user.name][:tags].add(usertag.tag)
    end
    d
  end

  def self.find_research_notes(tagnames, limit = 10)
    Node.research_notes.where(status: 1)
        .includes(:drupal_node_revision, :tag)
        .where('term_data.name IN (?)', tagnames)
        .order('node_revisions.timestamp DESC')
        .limit(limit)
  end
end
