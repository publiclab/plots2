class DrupalTag < ActiveRecord::Base
  attr_accessible :vid, :name, :description, :weight
  self.table_name = 'term_data'
  self.primary_key = 'tid'
  has_many :drupal_node_tag, :foreign_key => 'tid'

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
  validates :name, :format => {:with => /^[\w:-]*$/, :message => "can only include letters, numbers, and dashes"}

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

  def self.find_nodes_by_type(tagnames,type = "note",limit = 10)
    tids = DrupalTag.find(:all, :conditions => ['name IN (?)',tagnames]).collect(&:tid)
    nids = DrupalNodeCommunityTag.find(:all, :conditions => ["tid IN (?)",tids]).collect(&:nid)
    nids += DrupalNodeTag.find(:all, :conditions => ["tid IN (?)",tids]).collect(&:nid)
    DrupalNode.find_all_by_type type, :conditions => ["node.nid in (?)",nids.uniq], :order => "node_revisions.timestamp DESC", :limit => limit, :include => :drupal_node_revision
  end

  def self.find_nodes_by_type_with_all_tags(tagnames,type = "note",limit = 10)
    nids = false
    tagnames.each do |tagname|
      tids = DrupalTag.find(:all, :conditions => {:name => tagname}).collect(&:tid)
      tag_nids = DrupalNodeCommunityTag.find(:all, :conditions => ["tid IN (?)",tids]).collect(&:nid)
      tag_nids += DrupalNodeTag.find(:all, :conditions => ["tid IN (?)",tids]).collect(&:nid)
      nids = tag_nids if nids == false
      nids = nids & tag_nids
    end
    DrupalNode.find nids, :order => "nid DESC", :limit => limit
  end

  def self.find_popular_notes(tag,views = 20,limit = 10)
    tids = DrupalTag.find(:all, :conditions => {:name => tag}).collect(&:tid)
    nids = DrupalNodeCommunityTag.find(:all, :conditions => ["tid IN (?)",tids]).collect(&:nid)
    nids += DrupalNodeTag.find(:all, :conditions => ["tid IN (?)",tids]).collect(&:nid)
    DrupalNode.find_all_by_type "note", :conditions => ["node.nid in (?) AND node_counter.totalcount > (?)",nids.uniq,views], :order => "changed DESC", :limit => limit, :include => :drupal_node_counter
  end

  def self.exists?(tagname,nid)
    DrupalNodeCommunityTag.find(:all, :conditions => ['nid = ? AND term_data.name = ?',nid,tagname], :joins => :drupal_tag).length != 0
  end

end
