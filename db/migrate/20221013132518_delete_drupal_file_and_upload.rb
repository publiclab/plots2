class DeleteDrupalFileAndUpload < ActiveRecord::Migration[5.2]
  def change
    drop_table :files
    drop_table :upload
  end
end
