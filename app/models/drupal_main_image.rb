class DrupalMainImage < ActiveRecord::Base

  self.table_name = 'content_field_main_image'
  self.primary_key = 'vid'

  belongs_to :drupal_node, :foreign_key => 'nid', :dependent => :destroy
  belongs_to :drupal_file, :foreign_key => 'field_main_image_fid'

end
