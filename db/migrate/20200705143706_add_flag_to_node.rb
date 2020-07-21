class AddFlagToNode < ActiveRecord::Migration[5.2]
  def change
    add_column :node, :flag, :integer, :default => 0,  :null => false
  end
end
