class DrupalNodeCommunityTag < ActiveRecord::Base
  attr_accessible :nid, :tid, :uid, :date
  self.table_name = 'community_tags'
  self.primary_keys = :tid, :nid
  belongs_to :node, :foreign_key => 'nid'
  belongs_to :tag, :foreign_key => 'tid'
  belongs_to :drupal_users, :foreign_key => 'uid'
  accepts_nested_attributes_for :tag

  after_create :increment_count

  def increment_count
    tag = self.tag
    tag.count = 0 if tag.count.nil?
    tag.count += 1
    tag.save
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
    self.tag.name
  end

end
