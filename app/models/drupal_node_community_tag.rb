class DrupalNodeCommunityTag < ActiveRecord::Base
  self.table_name = 'community_tags'
  belongs_to :drupal_node, :foreign_key => 'nid'
  belongs_to :drupal_tag, :foreign_key => 'tid'
  belongs_to :drupal_users, :foreign_key => 'uid'
  accepts_nested_attributes_for :drupal_tag

end
