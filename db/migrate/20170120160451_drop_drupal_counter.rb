class DropDrupalCounter < ActiveRecord::Migration
  def up
    if table_exists? "node_counter"
      drop_table :node_counter
    end
  end

  def down
  end
end
