class ProfilePhotos < ActiveRecord::Migration
  def up
    # attachment (paperclip)
    add_column :rusers, :photo_file_name, :string
    add_column :rusers, :photo_content_type, :string
    add_column :rusers, :photo_file_size, :string
  end

  def down
    remove_column :rusers, :photo_file_name
    remove_column :rusers, :photo_content_type
    remove_column :rusers, :photo_file_size
  end
end
