class DrupalFile < ActiveRecord::Base
  # attr_accessible :title, :body
  set_table_name :files
  belongs_to :drupal_node, :foreign_key => 'nid'
  self.primary_key = 'fid'

end
