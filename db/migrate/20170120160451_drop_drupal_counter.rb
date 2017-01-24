class DropDrupalCounter < ActiveRecord::Migration
  def up
    drop_table :node_counter
  end

  def down
  end
end
