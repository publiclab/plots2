class CreateAnswers < ActiveRecord::Migration
  def up
    create_table :answers do |t|
      t.integer :uid, default: 0, null: false
      t.integer :nid, default: 0, null: false
      t.string :content, null: false
      t.integer :cached_likes, default: 0
      t.timestamps
    end
    add_index :answers, [:uid, :nid]
  end

  def down
    remove_index :answers, [:uid, :nid]
    drop_table :answers
  end
end
