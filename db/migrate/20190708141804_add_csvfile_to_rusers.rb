class AddCsvfileToRusers < ActiveRecord::Migration[5.2]
  def change
    add_column :rusers, :csvfile, :string
  end
end
