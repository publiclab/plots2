class AddIndexTermDataName < ActiveRecord::Migration
  def up
    add_index(:term_data, :name)
  end

  def down
    remove_index(:term_data, :name)
  end
end
