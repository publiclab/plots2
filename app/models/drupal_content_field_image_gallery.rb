class DrupalContentFieldImageGallery < ActiveRecord::Base
  self.table_name = 'content_field_image_gallery'

  belongs_to :drupal_node, :foreign_key => 'nid', :dependent => :destroy

  def image
    DrupalFile.find self.field_image_gallery_fid 
  end

end
