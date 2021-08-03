class DropContentFieldImageGallery < ActiveRecord::Migration[5.2]
  def change
    drop_table :content_field_image_gallery
  end
end
