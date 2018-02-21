class RemoveConstraintsForSqlite < ActiveRecord::Migration
  def up
    change_column :comments, :thread, :string, null: true
  end

  def down
  end
end
