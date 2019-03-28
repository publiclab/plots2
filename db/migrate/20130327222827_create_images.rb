class CreateImages < ActiveRecord::Migration[5.1]
  def up
    unless table_exists? "images"
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
  end

  def down
    drop_table :images
  end
end
