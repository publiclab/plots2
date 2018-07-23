class AddRevisionStatus < ActiveRecord::Migration[5.1]
  def up
    add_column :node_revisions, :status, :integer, :default => 1
  end

  def down
    remove_column :node_revisions, :status
  end
end
