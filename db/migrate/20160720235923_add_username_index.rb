class AddUsernameIndex < ActiveRecord::Migration
  def up
	add_index :rusers, :username
  end

  def down
	remove_index :rusers, :column => :username
  end
end
