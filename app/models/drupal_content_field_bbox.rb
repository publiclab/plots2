# do we need this in the schema? http://georuby.rubyforge.org/spatialadapter-doc/index.html 
# add_index "table_points", "geom", :spatial=>true

class DrupalContentFieldBbox < ActiveRecord::Base
  self.table_name = 'content_field_bbox'
  self.primary_key = 'vid'

  belongs_to :drupal_node, :foreign_key => 'nid'

end
