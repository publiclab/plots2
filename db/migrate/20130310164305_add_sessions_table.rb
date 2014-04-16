class AddSessionsTable < ActiveRecord::Migration
  def change
    unless table_exists? "rsessions"
      create_table :rsessions do |t|
        t.string :session_id, :null => false
        t.text :data
        t.timestamps
      end
    end
      

    unless index_exists? "rsessions", :session_id
      add_index :rsessions, :session_id
    end
    
    unless index_exists? "rsessions", :updated_at
      add_index :rsessions, :updated_at
    end
  end
end
