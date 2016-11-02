class DrupalNodeCommunityTag < ActiveRecord::Base
  attr_accessible :nid, :tid, :uid, :date
  self.table_name = 'community_tags'
  self.primary_keys = :tid, :nid
  belongs_to :drupal_node, :foreign_key => 'nid'
  belongs_to :drupal_tag, :foreign_key => 'tid'
  belongs_to :drupal_users, :foreign_key => 'uid'
  accepts_nested_attributes_for :drupal_tag

  after_create :increment_count

  def increment_count
    tag = self.tag
    tag.count = 0 if tag.count.nil?
    tag.count += 1
    tag.save
  end

  def node
    self.drupal_node
  end

  def tag
    self.drupal_tag
  end

  def author
    self.user
  end

  def user
    DrupalUsers.find_by_uid(self.uid).try(:user)
  end

  def drupal_user
    DrupalUsers.find self.uid
  end

  def name
    self.drupal_tag.name
  end

end
