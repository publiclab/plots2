class DrupalMainImage < ActiveRecord::Base
  # attr_accessible :title, :body
  set_table_name :content_field_main_image
  belongs_to :drupal_node, :foreign_key => 'nid'
  belongs_to :drupal_file, :foreign_key => 'field_main_image_fid'
  self.primary_key = 'vid'

end
