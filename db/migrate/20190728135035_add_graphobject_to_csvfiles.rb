class AddGraphobjectToCsvfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :csvfiles, :graphobject, :string
  end
end
