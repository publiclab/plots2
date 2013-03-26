class DrupalNodeCommunityTag < ActiveRecord::Base
  attr_accessible :nid, :tid, :uid, :date
  self.table_name = 'community_tags'
  self.primary_key = 'date' # slightly incorrect but will do, and allows for deletion
  belongs_to :drupal_node, :foreign_key => 'nid'
  belongs_to :drupal_tag, :foreign_key => 'tid'
  belongs_to :drupal_users, :foreign_key => 'uid'
  accepts_nested_attributes_for :drupal_tag

  def node
    self.drupal_node
  end

  def tag
    self.drupal_tag
  end

end
