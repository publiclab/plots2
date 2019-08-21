class ChangeGraphobjectToBeTextInCsvfiles < ActiveRecord::Migration[5.2]
  def change
    change_column :csvfiles, :graphobject, :text
  end
end
