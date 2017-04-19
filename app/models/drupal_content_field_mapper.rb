class DrupalContentFieldMapper < ActiveRecord::Base
  self.table_name = 'content_field_mappers'
  self.primary_key = 'vid'

  belongs_to :node, foreign_key: 'nid'
end
