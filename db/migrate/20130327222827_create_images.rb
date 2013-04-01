class CreateImages < ActiveRecord::Migration
  def up
    create_table :images do |t|
      t.string :title
      t.integer :uid
      t.integer :nid
      t.string :notes
      t.integer :version, :default => 0

      # attachment (paperclip)
      t.string :photo_file_name
      t.string :photo_content_type
      t.string :photo_file_size

      t.timestamps
    end
  end

  def down
    drop_table :images
  end
end
