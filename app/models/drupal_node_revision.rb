class DrupalNodeRevision < ActiveRecord::Base
  # attr_accessible :title, :body
  set_table_name :node_revisions
  belongs_to :drupal_node, :foreign_key => 'nid'

  self.primary_key = 'vid'

end
