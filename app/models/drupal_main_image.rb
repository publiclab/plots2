class DrupalMainImage < ApplicationRecord
  self.table_name = 'content_field_main_image'
  self.primary_key = :nid

  belongs_to :node, foreign_key: 'nid', dependent: :destroy
end
