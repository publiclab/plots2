class DrupalTag < ActiveRecord::Base
  attr_accessible :vid, :name, :description, :weight
  self.table_name = 'term_data'
  self.primary_key = 'tid'
  has_many :drupal_node_tag, :foreign_key => 'tid'
  has_many :drupal_node, :through => :drupal_node_tag do
    def filter_by_type(type,limit = 10)
      find(:all, :conditions => {:status => 1, :type => type}, :limit => limit, :order => "created DESC")
    end
  end

  has_many :drupal_node_community_tag, :foreign_key => 'tid'
  # this probably never gets used; tag.drupal_node will use the above definition.
  has_many :drupal_node, :through => :drupal_node_community_tag do
    def filter_by_type(type,limit = 10)
      find(:all, :conditions => {:status => 1, :type => type}, :limit => limit, :order => "created DESC")
    end
  end

  validates :name, :presence => :true
  validates :name, :format => {:with => /^[\w-]*$/, :message => "can only include letters, numbers, and dashes"}

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

  # clean up params to be a hash with defaults
  def self.find_nodes_by_type(tagnames,type,limit)
    tids = DrupalTag.find(:all, :conditions => ['name IN (?)',tagnames]).collect(&:tid)
    nids = DrupalNodeCommunityTag.find(:all, :conditions => ["tid IN (?)",tids]).collect(&:nid)
    nids += DrupalNodeTag.find(:all, :conditions => ["tid IN (?)",tids]).collect(&:nid)
    DrupalNode.find_all_by_type type, :conditions => ["node.nid in (?)",nids.uniq], :order => "node_revisions.timestamp DESC", :limit => limit, :include => :drupal_node_revision
  end

  def self.find_nodes_by_type_with_all_tags(tags,type,limit)
    node_ids = []
    tags.each do |tag|
      tag.drupal_node.filter_by_type(type).each do |node|
        node_ids << node.nid if (node.tags & tags).length == tags.length
      end
    end
    DrupalNode.find node_ids.uniq, :order => "nid DESC", :limit => limit
  end

  def self.find_popular_notes(tag,limit = 8)
    nodes = []
    self.find_by_name(tag).drupal_node.filter_by_type('note',limit).each do |node|
      nodes << node if node.totalcount > 20
    end
    nodes.uniq.sort{|a,b| b.created <=> a.created}
  end

end
