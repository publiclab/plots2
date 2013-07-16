class AddResetKey < ActiveRecord::Migration
  def up
    add_column :rusers, :reset_key, :string, :default => nil
  end

  def down
    remove_column :rusers, :reset_key
  end
end
