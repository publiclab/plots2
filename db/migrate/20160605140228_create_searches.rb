class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :key_words
      t.string :title
      t.string :user_id
      t.timestamps
    end
  end
end
