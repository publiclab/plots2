class DropDrupalUsers < ActiveRecord::Migration[5.1]
  def up
    if table_exists? "users"
      drop_table :users
    end
  end

  def down
  end
end
