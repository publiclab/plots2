class DrupalContentFieldMapEditor < ActiveRecord::Base
  self.table_name = 'content_field_map_editor'
  self.primary_key = 'vid'

  belongs_to :node, foreign_key: 'nid'
end
