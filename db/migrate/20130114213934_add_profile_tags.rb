class AddProfileTags < ActiveRecord::Migration
  def up
    create_table :tags do |t|
      t.string :key
      t.string :value
      t.string :user_id
      t.string :type # note, wiki, profile, admin
      t.text :body
      t.timestamps
    end
  end

  def down
    drop_table :tags
    remove_column :users, :lat
    remove_column :users, :lon
  end
end
