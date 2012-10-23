class Node < ActiveRecord::Migration
  def up
    create_table :nodes do |t|
      t.string :title
      t.string :user_id
      t.string :type # note, wiki
      t.text :body
      t.boolean :locked, :default => false
      t.boolean :published, :default => false
      t.timestamps
    end

    create_table :wiki_revisions do |t|
      t.string :user_id
      t.text :body
      t.text :notes
      t.integer :revision
      t.integer :node_id
      t.timestamps
    end

    create_table :wiki_revisions do |t|
      t.string :user_id
      t.text :body
      t.text :notes
      t.integer :revision
      t.integer :node_id
      t.timestamps
    end

    create_table :images do |t|
      # attachment (paperclip)
      t.string :photo_file_name
      t.string :photo_content_type
      t.string :photo_file_size
      t.timestamps
    end

    create_table :tags do |t|
      t.string :user_id
      t.string :key
      t.string :value
      t.integer :node_id
      t.boolean :blessed
      t.timestamps
    end

  end

  def down
    drop_table :nodes
    drop_table :wiki_revisions
    drop_table :images
    drop_table :tags
  end
end
