class CreateLikes < ActiveRecord::Migration[5.1]
  def change
    create_table :likes do |t|
      t.integer :likeable_id
      t.integer :user_id
      t.string :likeable_type

      t.timestamps
    end
  end
end
