class NodeTag < ApplicationRecord
  extend RawStats
  self.table_name = 'community_tags'
  self.primary_keys = :tid, :nid
  belongs_to :node, foreign_key: 'nid'
  belongs_to :tag, foreign_key: 'tid'
  belongs_to :users, foreign_key: 'uid'
  accepts_nested_attributes_for :tag

  after_create :increment_count

  def increment_count
    tag = self.tag
    tag.count = 0 if tag.count.nil?
    tag.count += 1
    tag.save
  end

  def user
    User.find(uid)
  end

  def author
    user
  end

  def name
    tag.name
  end

  def description
    tag.description if tag&.description && !tag.description.empty?
  end
end
