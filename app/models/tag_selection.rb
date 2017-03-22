class TagSelection < ActiveRecord::Base
  attr_accessible :following
  self.primary_keys = :user_id, :tid
  belongs_to :tag, foreign_key: :tid
  has_many :drupal_node_community_tags, foreign_key: :tid

  validates :user_id, presence: :true
  validates :tid, presence: :true
  validates :tag, presence: :true

  def user
    DrupalUsers.find_by_uid user_id
  end

  def tagname
    tag.name
  end
end
