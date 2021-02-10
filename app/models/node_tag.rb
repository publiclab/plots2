class NodeTag < ApplicationRecord
  extend RawStats
  self.table_name = 'community_tags'
  self.primary_keys = :tid, :nid
  belongs_to :node, foreign_key: 'nid'
  belongs_to :tag, foreign_key: 'tid'
  belongs_to :users, foreign_key: 'uid'
  has_many :tag_selections, foreign_key: 'tid'
  accepts_nested_attributes_for :tag

  after_create :update_count, :update_timestamp
  after_destroy :update_count

  def update_count
    tag.run_count # update count of tag usage
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

  def update_timestamp
    tag.update_activity_timestamp = DateTime.now
    tag.latest_activity_nid = nid
    tag.save
  end
end
