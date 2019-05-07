class CreateCsvfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :csvfiles do |t|
      t.integer :uid
      t.string :filename
      t.string :filepath
      t.string :filetitle
      t.text :filedescription

      t.timestamps
    end
  end
end
