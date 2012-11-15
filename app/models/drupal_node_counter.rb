class DrupalNodeCounter < ActiveRecord::Base
  self.table_name = 'node_counter'

  belongs_to :drupal_node, :foreign_key => 'nid'

end
