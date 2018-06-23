class DropDrupalCounter < ActiveRecord::Migration[5.1]
  def up
    if table_exists? "node_counter"
      drop_table :node_counter
    end
  end

  def down
  end
end
