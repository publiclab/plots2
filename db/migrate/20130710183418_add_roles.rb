class AddRoles < ActiveRecord::Migration[5.1]
  def up
    unless column_exists? "rusers", :role
      add_column :rusers, :role, :string, :default => "basic"
    end
  end

  def down
    remove_column :rusers, :role
  end
end
