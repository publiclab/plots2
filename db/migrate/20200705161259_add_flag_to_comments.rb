class AddFlagToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :flag, :integer, :default => 0,  :null => false
  end
end
