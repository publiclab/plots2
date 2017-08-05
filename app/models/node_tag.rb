class NodeTag < ActiveRecord::Base
  attr_accessible :nid, :tid, :uid, :date
  self.table_name = 'community_tags'
  self.primary_keys = :tid, :nid
  belongs_to :node, foreign_key: 'nid'
  belongs_to :tag, foreign_key: 'tid'
  belongs_to :drupal_users, foreign_key: 'uid'
  accepts_nested_attributes_for :tag

  after_create :increment_count

  def increment_count
    tag = self.tag
    tag.count = 0 if tag.count.nil?
    tag.count += 1
    tag.save
  end

  def author
    user
  end

  def user
    DrupalUsers.find_by_uid(uid).try(:user)
  end

  def drupal_user
    DrupalUsers.find uid
  end

  def name
    tag.name
  end
end
