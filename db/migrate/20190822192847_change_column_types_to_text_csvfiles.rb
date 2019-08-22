class ChangeColumnTypesToTextCsvfiles < ActiveRecord::Migration[5.2]
  def change
    change_column :csvfiles, :graphobject, :text
    change_column :csvfiles, :filestring, :text
    change_column :csvfiles, :filepath, :text
  end
end
