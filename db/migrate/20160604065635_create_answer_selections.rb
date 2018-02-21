class CreateAnswerSelections < ActiveRecord::Migration
  def change
    create_table :answer_selections do |t|
      t.integer :user_id
      t.integer :aid
      t.boolean :liking, default: false
      t.boolean :following, default: false 
    end
    add_index :answer_selections, [:user_id, :aid]
  end

  def down
    remove_index :answer_selections, [:user_id, :aid]
    drop_table :answer_selections
  end
end
