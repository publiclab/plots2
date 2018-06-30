class RemoveConstraintsForSqlite < ActiveRecord::Migration[5.1]
  def up
    change_column :comments, :thread, :string, null: true
  end

  def down
  end
end
