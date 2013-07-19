require 'php_serialize'

class DrupalContentFieldImageGallery < ActiveRecord::Base
  self.table_name = 'content_field_image_gallery'
  self.primary_keys = :vid,:nid

  belongs_to :drupal_node, :foreign_key => 'nid', :dependent => :destroy
  belongs_to :drupal_file, :foreign_key => 'field_image_gallery_fid', :dependent => :destroy

  def file
    self.drupal_file
  end

  def fid
    self.field_image_gallery_fid 
  end

  def image
    DrupalFile.find self.field_image_gallery_fid 
  end

  def description
    begin
      PHP.unserialize(self.field_image_gallery_data)['description']
    rescue
      ""
    end
  end

end
