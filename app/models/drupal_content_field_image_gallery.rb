require 'php_serialize'

class DrupalContentFieldImageGallery < ActiveRecord::Base
  self.table_name = 'content_field_image_gallery'
  self.primary_keys = :vid, :nid

  belongs_to :node, foreign_key: 'nid', dependent: :destroy
  belongs_to :drupal_file, foreign_key: 'field_image_gallery_fid', dependent: :destroy

  def file
    drupal_file
  end

  def fid
    field_image_gallery_fid
  end

  def image
    DrupalFile.find field_image_gallery_fid
  end

  def description
    PHP.unserialize(field_image_gallery_data)['description']
  rescue
    ''
  end
end
