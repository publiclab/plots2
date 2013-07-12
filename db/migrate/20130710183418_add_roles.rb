class AddRoles < ActiveRecord::Migration
  def up
    add_column :rusers, :role, :string, :default => "basic"
  end

  def down
    remove_column :rusers, :role
  end
end
