class AddIndexProfileValues < ActiveRecord::Migration[5.1]
  def up
    add_index(:profile_values, :uid)
  end

  def down
    remove_index(:profile_values, :uid)
  end
end
