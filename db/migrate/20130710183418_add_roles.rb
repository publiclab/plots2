class AddRoles < ActiveRecord::Migration
  def up
    unless column_exists? "rusers", :role
      add_column :rusers, :role, :string, :default => "basic"
    end
  end

  def down
    remove_column :rusers, :role
  end
end
