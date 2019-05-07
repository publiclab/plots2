class AddCsvfilesToRusers < ActiveRecord::Migration[5.2]
  def change
    add_column :rusers, :filename, :string
  end
end
