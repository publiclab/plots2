class AddSessionsTable < ActiveRecord::Migration
  def change
    create_table :rsessions do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
    end

    add_index :rsessions, :session_id
    add_index :rsessions, :updated_at
  end
end
