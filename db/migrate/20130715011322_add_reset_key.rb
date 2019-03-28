class AddResetKey < ActiveRecord::Migration[5.1]
  def up
    unless column_exists? "rusers", :reset_key
      add_column :rusers, :reset_key, :string, :default => nil
    end
  end

  def down
    remove_column :rusers, :reset_key
  end
end
