class AddAidToComments < ActiveRecord::Migration[5.1]
  def up
    add_column :comments, :aid, :integer, default: 0, null: false
  end

  def down
    remove_column :comments, :aid
  end
end
