class DrupalNodeTag < ActiveRecord::Base
  # attr_accessible :title, :body
  self.primary_key = 'id'
  self.table_name = 'term_node'
  belongs_to :drupal_node, :foreign_key => 'nid'
  belongs_to :drupal_tag, :foreign_key => 'tid'

end
