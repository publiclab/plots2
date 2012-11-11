class DrupalContentFieldBbox < ActiveRecord::Base
  self.table_name = 'content_field_bbox'

  belongs_to :drupal_node, :foreign_key => 'nid'

end
