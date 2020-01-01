class CreateCsvfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :csvfiles do |t|
      t.integer :uid
      t.string :filetitle
      t.text :filedescription
      t.string :filepath
      t.string :filename
      t.string :filestring

      t.timestamps
    end
  end
end
