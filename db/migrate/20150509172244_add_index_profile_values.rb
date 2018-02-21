class AddIndexProfileValues < ActiveRecord::Migration
  def up
    add_index(:profile_values, :uid)
  end

  def down
    remove_index(:profile_values, :uid)
  end
end
