class DrupalNodeCommunityTag < ActiveRecord::Base
  self.primary_key = 'id'
  self.table_name = 'community_tags'
  belongs_to :drupal_node, :foreign_key => 'nid'
  belongs_to :drupal_tag, :foreign_key => 'tid'

end
