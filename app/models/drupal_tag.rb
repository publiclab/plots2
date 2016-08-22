class DrupalTag < ActiveRecord::Base
  attr_accessible :vid, :name, :description, :weight
  self.table_name = 'term_data'
  self.primary_key = 'tid'

  has_many :tag_selection, :foreign_key => 'tid'
  has_many :drupal_node_community_tag, :foreign_key => 'tid'

  # we're not really using the filter_by_type stuff here:
  has_many :drupal_node, :through => :drupal_node_tag do
    def filter_by_type(type,limit = 10)
      find(:all, :conditions => {:status => 1, :type => type}, :limit => limit, :order => "created DESC")
    end
  end

  has_many :drupal_node_community_tag, :foreign_key => 'tid'

  # the following probably never gets used; tag.drupal_node will use the above definition.
  # also, we're not really using the filter_by_type stuff here:
  has_many :drupal_node, :through => :drupal_node_community_tag do
    def filter_by_type(type,limit = 10)
      find(:all, :conditions => {:status => 1, :type => type}, :limit => limit, :order => "created DESC")
    end
  end

  validates :name, :presence => :true
  validates :name, :format => {:with => /^[\w\.:-]*$/, :message => "can only include letters, numbers, and dashes"}
  #validates :name, :uniqueness => { case_sensitive: false }

  def id
    self.tid
  end

  def run_count
    self.count = DrupalNodeCommunityTag.where(:tid => self.tid).count
    self.save
  end

  def subscriptions
    self.tag_selection
  end

  # nodes this tag has been used on
  def nodes
    DrupalNode.where(nid: self.drupal_node_community_tag.collect(&:nid))
  end

  def is_community_tag(nid)
    !self.drupal_node_community_tag.find_by_nid(nid).nil?
  end

  def belongs_to(current_user, nid)
    node_tag = self.drupal_node_community_tag.find_by_nid(nid)
    node_tag && node_tag.uid == current_user.uid || node_tag.node.uid == current_user.uid
  end

  # finds highest viewcount nodes
  def self.find_top_nodes_by_type(tagname, type = "wiki", limit = 10)
    DrupalNode.find_all_by_type type, :conditions => ['term_data.name = ?', tagname], :order => "node_counter.totalcount DESC", :limit => limit, :include => [:drupal_node_counter, :drupal_node_community_tag, :drupal_tag]
  end

  # finds recent nodes
  def self.find_nodes_by_type(tagnames, type = "note", limit = 10)
    DrupalNode.where(status: 1, type: type)
              .includes(:drupal_node_revision, :drupal_tag)
              .where('term_data.name IN (?)', tagnames)
              .order("node_revisions.timestamp DESC")
              .limit(limit)
  end

  # just like find_nodes_by_type, but searches wiki pages, places, and tools
  def self.find_pages(tagnames,limit = 10)
    self.find_nodes_by_type(tagnames,['page','place','tool'],limit)
  end

  def self.find_nodes_by_type_with_all_tags(tagnames,type = "note",limit = 10)
    nids = false
    tagnames.each do |tagname|
      tids = DrupalTag.find(:all, :conditions => {:name => tagname}).collect(&:tid)
      tag_nids = DrupalNodeCommunityTag.find(:all, :conditions => ["tid IN (?)",tids]).collect(&:nid)
      nids = tag_nids if nids == false
      nids = nids & tag_nids
    end
    DrupalNode.find :all, :conditions => ["nid IN (?)",nids], :order => "nid DESC", :limit => limit
  end

  def self.find_popular_notes(tagname,views = 20,limit = 10)
    DrupalNode.find_all_by_type "note", :conditions => ['term_data.name = ? AND node_counter.totalcount > (?)', tagname, views], :order => "node.nid DESC", :limit => limit, :include => [:drupal_node_counter, :drupal_node_community_tag, :drupal_tag]
  end

  def self.exists?(tagname,nid)
    DrupalNodeCommunityTag.find(:all, :conditions => ['nid = ? AND term_data.name = ?',nid,tagname], :joins => :drupal_tag).length != 0
  end

  def self.is_powertag?(tagname)
    !tagname.match(':').nil?
  end

  def self.follower_count(tagname)
    TagSelection.joins(:drupal_tag).where(['term_data.name = ?',tagname]).count
  end

  def self.followers(tagname)
    uids = TagSelection.joins(:drupal_tag)
                       .where('term_data.name = ?', tagname)
                       .collect(&:user_id)
    DrupalUsers.where(['uid in (?)', uids])
               .collect(&:user)
  end

  # optimize this too!
  def weekly_tallies(type = "note", span = 52)
    weeks = {}
    tids = DrupalTag.where('name IN (?)', [self.name])
                    .collect(&:tid)
    nids = DrupalNodeCommunityTag.where("tid IN (?)", tids)
                                 .collect(&:nid)
    (1..span).each do |week|
      weeks[span - week] = DrupalTag.nodes_for_period(
        type,
        nids,
        (Time.now.to_i - week.weeks.to_i).to_s,
        (Time.now.to_i - (week - 1).weeks.to_i).to_s
      ).count
    end
    weeks
  end

  def self.nodes_for_period(type, nids, start, finish)
    DrupalNode.select([:created, :status, :type, :nid])
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
  # Accepts array of DrupalTags, outputs array of users as:
  # {user: <user>, tags: [<tags>]}
  # Used in subscription_mailer
  def self.subscribers(tags)
    tids = tags.collect(&:tid)
    # include special tid for indiscriminant subscribers who want it all!
    all_tag = DrupalTag.find_by_name("everything")
    tids += [all_tag.tid,] if all_tag
    usertags = TagSelection.where("tid IN (?) AND following = ?", tids, true)
    d = {}
    usertags.each do |usertag|
      # For each row of (user,tag), build a user's tag subscriptions 
      if (usertag.tid == all_tag) and (usertag.tag.nil?)
        puts "WARNING: all_tag tid " + String(all_tag) + " not found for DrupalTag! Please correct this!"
        next
      end
      d[usertag.user.name] = {:user => usertag.user}
      d[usertag.user.name][:tags] = Set.new if d[usertag.user.name][:tags].nil?
      d[usertag.user.name][:tags].add(usertag.tag)
    end
    d
  end

  def self.find_research_notes(tagnames, limit = 10)
    DrupalNode.research_notes.where(status: 1)
              .includes(:drupal_node_revision, :drupal_tag)
              .where('term_data.name IN (?)', tagnames)
              .order("node_revisions.timestamp DESC")
              .limit(limit)
  end

end
