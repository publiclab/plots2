class AddReferenceToComments < ActiveRecord::Migration
  def change
    add_column :comments, :reference, :string
  end
end
