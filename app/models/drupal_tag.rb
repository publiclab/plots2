class DrupalTag < ActiveRecord::Base
  attr_accessible :vid, :name, :description, :weight
  self.table_name = 'term_data'
  self.primary_key = 'tid'
  has_many :drupal_node_tag, :foreign_key => 'tid'
  #has_many :drupal_users, :through => :drupal_node_tag, :foreign_key => 'uid'

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

  def id
    self.tid
  end

  def nodes
    ids = []
    self.drupal_node_tag.each do |node_tag|
      ids << node_tag.nid
    end
    DrupalNode.find :all, :conditions => ['status = 1 AND nid IN ('+ids.uniq.join(',')+')'], :order => "nid DESC"
  end 

  def is_community_tag(nid)
    !self.drupal_node_community_tag.find_by_nid(nid).nil?
  end

  def belongs_to(current_user,nid)
    node_tag = self.drupal_node_community_tag.find_by_nid(nid)
    node_tag && node_tag.uid == current_user.uid || node_tag.node.uid == current_user.uid
  end

  # finds highest viewcount nodes
  def self.find_top_nodes_by_type(tagname,type = "wiki",limit = 10)
    tag = DrupalTag.where(:name => tagname).first
    DrupalNode.find_all_by_type type, :conditions => ['community_tags.tid = ?', tag.tid], :order => "node_counter.totalcount DESC", :limit => limit, :include => [:drupal_node_counter, :drupal_node_community_tag]
  end

  # finds recent nodes
  def self.find_nodes_by_type(tagnames,type = "note",limit = 10)
    DrupalNode.where(:status => 1, :type => type).includes(:drupal_node_revision,:drupal_tag).where('term_data.name IN (?)',tagnames).order("node_revisions.timestamp DESC").limit(limit)
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

  def self.find_popular_notes(tag,views = 20,limit = 10)
    tag = DrupalTag.where(:name => tag).first
    DrupalNode.find_all_by_type "note", :conditions => ['community_tags.tid = ? AND node_counter.totalcount > (?)', tag.tid, views], :order => "node.nid DESC", :limit => limit, :include => [:drupal_node_counter, :drupal_node_community_tag]
  end

  def self.exists?(tagname,nid)
    DrupalNodeCommunityTag.find(:all, :conditions => ['nid = ? AND term_data.name = ?',nid,tagname], :joins => :drupal_tag).length != 0
  end

  def self.follower_count(tagname)
    TagSelection.joins(:drupal_tag).where(['term_data.name = ?',tagname]).count
  end

  def self.followers(tagname)
    uids = TagSelection.joins(:drupal_tag).where(['term_data.name = ?',tagname]).collect(&:user_id)
    DrupalUsers.find(:all, :conditions => ['uid in (?)',uids]).collect(&:user)
  end

  # optimize this too!
  def weekly_tallies(type = "note",span = 52)
    weeks = {}
    tids = DrupalTag.find(:all, :conditions => ['name IN (?)',[self.name]]).collect(&:tid)
    nids = DrupalNodeCommunityTag.find(:all, :conditions => ["tid IN (?)",tids]).collect(&:nid)
    (0..span).each do |week|
      weeks[span-week] = DrupalNode.count :all, :select => :created, :conditions => ['type = "'+type+'" AND status = 1 AND nid IN ('+nids.uniq.join(',')+') AND created > '+(Time.now.to_i-week.weeks.to_i).to_s+' AND created < '+(Time.now.to_i-(week-1).weeks.to_i).to_s]
    end
    weeks
  end

end
