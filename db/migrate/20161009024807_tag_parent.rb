class TagParent < ActiveRecord::Migration
  def up
    add_column :term_data, :parent, :string
    add_index :term_data, :parent
    drop_table :tags # clean up never-finished tag additions
  end

  def down
    remove_index :term_data, :parent
    remove_column :term_data, :parent
    create_table :tags do |t|
      t.string :key
      t.string :value
      t.string :user_id
      t.string :type # note, wiki, profile, admin
      t.text :body
      t.timestamps
    end
  end
end
